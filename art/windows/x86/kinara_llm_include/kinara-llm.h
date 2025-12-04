/*
 * Copyright (c) 2024, Kinara, Inc. All rights reserved.
 */

#ifndef KINARA_LLM_H_
#define KINARA_LLM_H_

#include <string>
#include <cstdint>
#include <vector>
#include <queue>
#include <thread>
#include <mutex>
#include <map>
#include <variant>
#include <set>
#include <memory>
#include <atomic>
#include <chrono>
using namespace std::chrono_literals;

#if defined(_WIN32)
#define EXPORT __declspec(dllexport)
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <powerbase.h>
#include <powrprof.h>
#else
#define EXPORT
#endif

struct Internal;

enum class GenerateStatus {
    Generating,
    Stopped,
    Error,
    Abort,
};

/*
 * for more details refer kinara-llm\doc\state_flow_*.pdf
*/
enum class KinaraLLMState {
    Init,
    Proxy_Connected,
    Model_Loaded,
    Tokenizer_Set,
    Model_Loaded_Tokenizer_Set,
    Running_Prompt
};

/*
 * for more details refer kinara-llm\doc\state_flow_*.pdf
*/
enum class KinaraLLMEvent {
    Proxy_Connected,
    Proxy_Disconnected,
    Model_Loaded,
    Model_Unloaded,
    Tokenizer_Set,
    Tokenizer_Unset,
    Running_Prompt,
    Stopping_Prompt
};

struct PerformanceStatistic {
    // LLM Model
    std::chrono::milliseconds llm_load_duration = 0ms;
    std::chrono::milliseconds llm_unload_duration = 0ms;
    std::chrono::milliseconds llm_cancel_duration = 0ms;
    // Tokenizer
    std::chrono::milliseconds tokenizer_load_duration = 0ms; // *unsupported*
    // Generation
    std::chrono::milliseconds llm_first_infer_duration = 0ms;
    std::chrono::milliseconds llm_prompt_evaluation_duration = 0ms;
    std::chrono::milliseconds llm_generate_next_token_duration = 0ms;
    std::chrono::milliseconds llm_token_generation_time = 0ms;
    double llm_average_token_per_second = 0.0;
    int input_token_num = 0;
    int generated_token_num = 0;
};

typedef std::map<std::string, std::variant<int, double, float, std::string>> Kinara_Params_MAP;

/*
 * n_ctx : context windows size
 * top_k : sampling technique, used in post processing. Consider only top k elemets from the model output (logit vector) and discard reset of elements.
 *         range is [1, vocab size].
 *         if top_k is equal to 0, top_k sampling will not be applied.
 * top_p : sampling technique, used in post processing. Consider top elements whose combined probability sums  up to probability p.
 *         range is (0.0, 1.0].
 *         if top_p is equal to 0.0, top_p sampling will not be applied.
 * temperature : used in post processing. A value less then 1 increase the gap between scores of elements and a value more then 1 reduces the gap between scores of elements
 *               increasing probability to select elements which otherwise won't be selected.
 *               common range is (0.0, 2.0]
 *               if temperature is equal to 0.0, temperature won't be applied.
 * Note: if top_k, top_p and temperature all are zero, Element with max score (after repeat penalty) will always be selected during post processing.
 * repeat_penalty : used in post processing. It is used to decrease the score of tokens which are previously selected in output.
 *                  range is (1, max], recommended value 1.2
 *                  if repeat_penalty is less then equal to 1.0 it will not be applied.
 * generate_max_tokens : Prompt will stop after generating specified number of tokens. There is a max token limit for every model, it will automatically stop after that.
 *                       range is [1, max]
 * seed : it is used to make results reproducible. Random number generator used during sampling will take seed to generate reproducible random number sequence.
 *        if seed is equal to 0, a random seed will be used.
 * log_mask : *unsupported*
 * n_vocab : *unsupported*, (value read internally from model.dvm)
 * target_prompt_post_mcp : supported values [0,1],
 *                          0 : run post processing for prompt inference on host device
 *                          1 : run post processing for prompt inference on ara device
 * target_prompt_pre_mcp : supported values [0,1],
 *                          0 : run pre processing for prompt inference on host device
 *                          1 : run pre processing for prompt inference on ara device
 * target_token_post_mcp : supported values [0,1],
 *                          0 : run post processing for token inference on host device
 *                          1 : run post processing for token inference on ara device
 * target_token_pre_mcp : supported values [0,1],
 *                          0 : run pre processing for token inference on host device
 *                          1 : run pre processing for token inference on ara device
*/
struct Kinara_Params {
    int32_t n_ctx = 0;
    int32_t top_k = 0;
    double top_p = 0.0;
    double temperature = 0.0;
    double repeat_penalty = 0.0;
    int32_t repeat_last_n = 0;
    int32_t seed = 0;
    std::string log_mask = "";
    int32_t generate_max_tokens = 4096;
    int32_t n_vocab = 0;
    int32_t ngram_penalty = 0;
    int32_t target_token_post_mcp = 0;
    int32_t target_token_pre_mcp = 0;
    int32_t target_prompt_post_mcp = 0;
    int32_t target_prompt_pre_mcp = 0;
    int32_t is_model_specd = 0;
    double frequency_penalty = 0;
    std::string suppress_token_type = "";
    double suppress_penalty = 0.0;
    std::string model = "";
};

struct Pre {
    char* input_embeddings = nullptr;
    char* input_embeddings_scales = nullptr;
    std::vector<uint32_t> token_ids;
};

struct Message {
    std::string role;
    std::string content;
};

/*
 * This encode and decode functionality should be implemented by client
 *
 * 此编码和解码功能应由客户端实现
*/
class EXPORT TokenizerInterface{
    public:
        virtual std::vector<int64_t> encode(const std::string& str) = 0;
        virtual bool skip_token_id(int64_t) = 0;
        virtual std::vector<int64_t> apply_chat_template(std::vector<Message> messages, bool add_generation_prompt) = 0;
        virtual std::vector<std::string> batch_decode(std::vector<int64_t>) = 0;
        virtual ~TokenizerInterface() {}
        virtual std::string decode(int64_t) = 0;
        // Deprecated Functions
        virtual size_t get_pad_token_id() {
            return 0;
        };
        virtual size_t get_eos_token_id() {
            return 0;
        };
        virtual size_t get_vocab_size() {
            return 0;
        };
        virtual bool terminating_token_id(int64_t) {
            return false;
        };
        // Required for LLAVA model usecase
        virtual std::vector<uint8_t> get_pixels(const std::string& image_path) {
            return {};
        }
        
};



class EXPORT ApiInterface {
    private:
        KinaraLLMState _kinara_llm_state;
        Kinara_Params _params;
        char* _embedding_lookup = nullptr;
        char* _embedding_scale_lookup = nullptr;
        size_t _embedding_lookup_size;
        std::shared_ptr<Internal> _dv;
        std::shared_ptr<TokenizerInterface> _tokenizer;
        std::atomic<GenerateStatus> _generate_status = GenerateStatus::Stopped;
        std::mutex _output_tokens_mtx;
        std::mutex _output_tokens_ids_mtx;
        std::queue<std::string> _output_tokens;
        std::queue<uint32_t> _output_tokens_ids;
        std::thread _generate_stream_thread;
        PerformanceStatistic _performance_statistics;
        std::vector<int16_t> _logits_vector;
        std::string config_path;
        std::vector<int64_t> _repeated_token_ids;
        std::vector<Message> messages;
        std::string _utf8_buf;
        char *_img_embeddings = nullptr;
        char *_img_embeddings_scale = nullptr;
        

        void _set_generate_status(GenerateStatus generate_status);
        
        std::vector<uint32_t> _generate_next_token(std::vector<uint32_t> token_id);
        std::vector<uint32_t>  _generate_first_token(const std::string& prompt);
        template<typename T>
        void _generate_stream(const std::vector<T> &token_ids);

        template<typename T>
        std::vector<uint32_t>  _generate_first_token(const std::vector<T> token_ids);
        
        std::shared_ptr<Pre> _pre(const std::string& prompt);

        template<typename T>
        std::shared_ptr<Pre> _pre(const std::vector<T> &token_ids);
        template<typename T>
        uint32_t _post(std::vector<T>& logits_vector, int draft_token_id = -1, double draft_token_probability = -1.0);
        bool _is_tokenizer_compatible();

        void _process_kinara_llm_event(KinaraLLMEvent event);
        std::string _get_config(std::string key);

        size_t _get_pad_token_id();
        size_t _get_eos_token_id();
        size_t _get_bos_token_id();
        size_t _get_vocab_size();
        //void _generate_stream_v2(const std::string prompt);
       // std::vector<uint32_t> _generate_first_tokens_v2(const std::string& prompt);
       // std::vector<uint32_t> _generate_next_tokens_v2(std::vector<uint32_t>);

    public:

        #ifdef _WIN32
        void handle_power_state_change(ULONG Type);
        #endif

        ApiInterface(std::string config_file);
        ~ApiInterface();

        bool is_endpoint_usable();

        /*
         * api_loadmodel(), loads LLM model into Kinara Ara-2 device
         * and load embeddings file into RAM.
         * 
         * api_loadmodel()，将LLM模型加载到Kinara Ara-2设备中并将嵌入文件加载到RAM中。
        */
        int api_loadmodel(std::string& model_file_path);
        int api_loadmodel(std::string& model_file_path, std::string& embedding_file_path);
        int api_loadmodel(std::string& model_file_path, std::string& embedding_file_path, std::string& embedded_wts_scales);
        int api_loadmodel();

        /*
         * These params are used to select post processing strategy during post processing step
         *
         * 这些参数用于在后处理步骤中选择后处理策略
        */
        int set_params(const Kinara_Params_MAP& params_map);

        /*
        * Set image embeddings for llava model
        * Pass empty paths to unset the image embeddings
        */
        int set_image_embeddings(std::string img_embeddings_file_path, std::string img_embeddings_scale_file_path);
        int set_image_embeddings(char* img_embedding_lookup, char* img_embedding_scale_lookup);

        /*
         * api_generate_stream(), This is an asynchronous API.
         * It starts a thread which performs inferences in loop until Max token generation length is reached.
         * All generated tokens are stored in _output_tokens vector.
         * New call to this function will be rejected until previous stream is finished.
         * 
         * api_generate_stream()，这是一个异步API。
         * 它启动一个线程，在循环中执行推理，直到达到最大令牌生成长度。
         * 所有生成的令牌都存储在 _output_tokens 向量中。
         * 对此函数的新调用将被拒绝，直到上一个流完成。
        */
        int api_generate_stream(const std::string& prompt);
        int api_generate_stream(const std::string& prompt, std::string img_embeddings_file_path, std::string img_embeddings_scale_file_path, bool new_image);
        int api_generate_stream(const std::string& prompt, char* img_embedding_lookup, char* img_embedding_scale_lookup, bool new_image);

        int api_generate_stream(const std::vector<int64_t>& token_ids);

        /*
         * api_generate_status(), This API returns the status of last started stream.
         * The status are self explanatory, Abort is when api_stop() is called to stop the generating stream.
         * 
         * api_generate_status()，该API返回最后启动的流的状态。
         * 状态是不言自明的，中止是当调用 api_stop() 来停止生成流时。
        */
        GenerateStatus api_generate_status();

        /*
         * Remove the token from _output_tokens and return.
         * If not token is available returns empty string.
         * 
         * 从 _output_tokens 中删除令牌并返回。
         * 如果没有可用的令牌，则返回空字符串。
        */
        std::string api_get_generated_token();

        uint32_t api_get_generated_token_ids();

        /*
         * api_generate() is a blocking API. It waits for all tokens to be generated and returns all generated token at once.
         *
         * api_generate() 是一个阻塞 API。它等待所有令牌生成并立即返回所有生成的令牌。
        */
        std::string api_generate(const std::string& prompt);

        /*
         * api_set_tokenizer() allows client to provide pointer to the tokenizer.
         * Client need to implement TokenizerInterface and provide shared pointer.
         * Different LLM model might use different tokenizer.
         * If tokenizer is not set a prompt can't be processed.
         * 
         * api_set_tokenizer() 允许客户端提供指向标记生成器的指针。
         * 客户端需要实现TokenizerInterface并提供共享指针。
         * 不同的LLM模型可能使用不同的分词器。
         * 如果未设置分词器，则无法处理提示。
        */
        int api_set_tokenizer(std::shared_ptr<TokenizerInterface> tokenizer);
        std::shared_ptr<TokenizerInterface> api_get_tokenizer();

        /*
         * Return saved performance statistics
         *
         * 返回保存的性能统计数据
        */
        PerformanceStatistic get_performance_statistics();
        void reset_performance_statistics();
        void display_performance_statistic();
        std::string get_time_first_token();
        double get_time_token_sec();

        /*
         * api_reset(), resets the _params and _performance_statistics to default values.
         *
         * api_reset()，将 _params 和 _performance_statistics 重置为默认值。
        */
        void api_reset();

        /*
         * api_unloadmodel(),
         * If a prompt is running it will Abort that.
         * Unload the model and removed embeddings from memory.
         * Also records time taken to unload the model and remove embeddings from memory in llm_unload_duration of performance statistics.
         * 
         * api_unloadmodel(),
         * 如果提示正在运行，它将中止该提示。
         * 卸载模型并从内存中删除嵌入。
         * 还在性能统计数据的 llm_unload_duration 中记录卸载模型和从内存中删除嵌入所需的时间。
        */
        bool api_unloadmodel();

        /*
         * get_kinara_llm_state(), returns the current state of application.
         *
         * get_kinara_llm_state()，返回应用程序的当前状态。
        */
        KinaraLLMState get_kinara_llm_state();

        /*
         * api_stop(), Aborts the currently running generate stream.
         *
         * api_stop()，中止当前运行的生成流。
        */
        bool api_stop();

        /*
         * Returns kinara-llm.dll version
         *
         * 返回 kinara-llm.dll 版本
        */
        std::string get_version();
};

#endif // KINARA_LLM_H_