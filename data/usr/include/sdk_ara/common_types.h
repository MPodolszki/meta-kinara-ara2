/*
 * Copyright (c) 2018-25, Kinara, Inc. All rights reserved.
 * Copyright 2026 NXP
 *
 * NXP Proprietary. This software is owned or controlled by NXP and may only be
 * used strictly in accordance with the applicable license terms. By expressly
 * accepting such terms or by downloading, installing, activating and/or
 * otherwise using the software, you are agreeing that you have read, and that
 * you agree to comply with and are bound by, such license terms. If you do not
 * agree to be bound by the applicable license terms, then you may not retain,
 * install, activate or otherwise use the software.
 *
 */

#pragma once
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

namespace ara::ep {

/**
 * @brief Data type of tensor elements.
 *
 * Represents the primitive element type of the tensor buffer, such as float32
 * or int8. This is necessary to correctly interpret the raw buffer.
 */
enum class AraDataType : int32_t {
  UNDEFINED = 0,
  FLOAT32 = 1,
  INT32 = 2,
  UINT8 = 3,
  INT8 = 4,
  FLOAT16 = 5,
  INT64 = 6,
  BOOL = 7,
  BFLOAT16 = 8
  // Add more as needed
};

/**
 * @brief Status codes returned by the Runner interface.
 */
enum class AraRunnerStatusCode {
  SUCCESS,  ///< Inference or operation completed successfully
  // session related
  ARA_SESSION_CREATION_FAILURE,  ///< Failed to initialize ara runtime session
  ARA_EP_INIT_FAILURE,           ///< Failed to initialize ep grp
  ARA_EP_DEINIT_FAILURE,         ///< Failed to deinitialize ep grp
  ARA_SESSION_CLOSE_FAILURE,     ///< Failed to initialize ara runtime session
  // model related
  INCOMPATIBLE_MODEL_VERSION,  ///< The provided model is not supported
  ARA_MODEL_LOAD_FAILURE,      ///< Ara model load to proxy failed
  ARA_MODEL_UNLOAD_FAILURE,    ///< Ara model unload to proxy failed
  // inference related
  INFERENCE_TIMEOUT,  ///< Inference timed out
  INFERENCE_FAILURE,  ///< Inference failed (to handle miscellaneous reasons)
  INPUT_BUFFER_ALLOCATION_FAILURE,   ///< Input buffer allocation failed by
                                     ///< Target>
  OUTPUT_BUFFER_ALLOCATION_FAILURE,  ///< Output buffer allocation failed by
                                     ///< Target>
  INFERENCE_PREPROCESS_FAILURE,      ///< Preprocessing infer output
                                     ///< failed(quantization for cnn models)
  INFERENCE_POSTPROCESS_FAILURE,     ///< Postprocessing infer output
                                     ///< failed(dequantization for cnn models)
  HOST_MEM_ALLOCATION_FAILURE,  ///< Failed to allocate memory on host (malloc,
                                ///< new etc. failed)
  // misc failure status
  ARA_RUNNER_FAILURE
};

/**
 * @struct ARABinaryContext
 * @brief Holds the compiled binary(dvm) data and its size for a model or
 * subgraph.
 *
 * This struct encapsulates the binary data buffer and its length,
 * typically used to store the output of a compilation process.
 */
struct ARABinaryContext {
  /**
   * @brief Pointer to the compiled binary data buffer.
   *
   * Uses a unique_ptr to manage the memory automatically.
   */
  std::unique_ptr<unsigned char[]> data;

  /**
   * @brief Size of the binary data buffer in bytes.
   */
  size_t size = 0;

  std::string model_name;
};

/**
 * @brief Indicates memory location of the tensor buffer.
 */
enum class AraRunnerTensorLocation {
  CPU,        ///< Tensor resides in CPU memory
  ARA_DEVICE  ///< Tensor resides in device-specific memory
};

/**
 * @brief Represents a tensor for inference input/output.
 */
struct AraRunnerTensor {
  void* buffer = nullptr;  ///< Pointer to the raw tensor buffer
  AraDataType data_type =
      AraDataType::UNDEFINED;               ///< Data type of elements in buffer
  std::vector<int64_t> shape;               ///< Tensor shape (dimensions)
  AraRunnerTensorLocation tensor_location;  ///< Memory location of the tensor
};

using AraRunnerTensors = std::vector<AraRunnerTensor>;
using TensorDim = std::vector<int64_t>;

/**
 * @brief Options used to initialize the Runner.
 */
struct AraRunnerOptions {
  uint64_t araep_uid;  ///< UId for AraExecutinProvider instance
};

}  // namespace ara::ep