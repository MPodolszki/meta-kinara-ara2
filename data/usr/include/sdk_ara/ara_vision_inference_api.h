/*
 * Ara-2 Vision Inference API - API Header
 *
 * Copyright (c) 2020-2025 Kinara Inc.
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

#ifndef ARA_VISION_INFERENCE_API_H
#define ARA_VISION_INFERENCE_API_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

// Symbol export/import macros
#if defined(_WIN32) || defined(__CYGWIN__)
  #ifdef ARA_VISION_API_EXPORT
    #define ARA_API __declspec(dllexport)
  #else
    #define ARA_API __declspec(dllimport)
  #endif
#else
  #ifdef ARA_VISION_API_EXPORT
    #define ARA_API __attribute__((visibility("default")))
  #else
    #define ARA_API
  #endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* ============================================================
 * Common Types
 * ============================================================ */

typedef void* ara_context_t;

typedef enum {
    ARA_VISION_SUCCESS = 0,
    ARA_VISION_ERROR_INVALID_PARAM = -1,
    ARA_VISION_ERROR_INIT_FAILED = -2,
    ARA_VISION_ERROR_INFERENCE_FAILED = -3,
    ARA_VISION_ERROR_OUT_OF_MEMORY = -4,
    ARA_VISION_ERROR_NOT_READY = -5,
    ARA_VISION_ERROR_THREAD_FAILED = -6
} ara_status_t;

typedef enum {
    ARA_VISION_BUFFER_FORMAT_RGBA = 0,
    ARA_VISION_BUFFER_FORMAT_RGB_PLANAR = 1,
    ARA_VISION_BUFFER_FORMAT_BGR_PLANAR = 2,
    ARA_VISION_BUFFER_FORMAT_FLOAT32 = 3,
    ARA_VISION_BUFFER_FORMAT_INT8 = 4,
    ARA_VISION_BUFFER_FORMAT_INT16 = 5,
    ARA_VISION_BUFFER_FORMAT_RGB = 6            // NEW: Interleaved RGB input
} ara_buffer_format_t;

typedef struct {
    unsigned char* data;     // Pointer to buffer data
    size_t size;             // Total size in bytes
    int width;               // Image width
    int height;              // Image height
    int stride;              // Bytes per row (can be > width * channels)
    int channels;            // Number of channels
    ara_buffer_format_t format;
} ara_buffer_t;

typedef enum {
    ARA_VISION_MODEL_TYPE_DETECTION = 0,
    ARA_VISION_MODEL_TYPE_POSE = 1,
    ARA_VISION_MODEL_TYPE_SEGMENTATION = 2,
    ARA_VISION_MODEL_TYPE_CLASSIFICATION = 3
} ara_model_type_t;

/* ============================================================
 * Performance Monitoring
 * ============================================================ */

typedef struct {
    uint64_t preprocess_time_us;
    uint64_t inference_time_us;
    uint64_t postprocess_time_us;
    uint64_t total_time_us;
    uint32_t frame_count;
} ara_performance_stats_t;

/**
 * Get performance statistics
 * @param ctx Context handle
 * @param stats Output statistics
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_get_performance_stats(
    ara_context_t ctx,
    ara_performance_stats_t* stats
);

/**
 * Reset performance statistics
 * @param ctx Context handle
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_reset_performance_stats(ara_context_t ctx);

/* ============================================================
 * Preprocessing API
 * ============================================================ */

/**
 * Initialize preprocessing context
 * Thread-safe after initialization.
 * @param model_path Path to model file (to get input dimensions)
 * @param ctx Output context handle
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_preprocess_init(
    const char* model_path,
    ara_context_t* ctx
);

/**
 * Preprocess RGBA buffer to model input format
 * Uses SIMD optimization when available.
 * @param ctx Preprocessing context
 * @param input Input buffer (RGBA format)
 * @param output Output buffer (model input format, allocated by caller)
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_preprocess_rgba_to_model_input(
    ara_context_t ctx,
    const ara_buffer_t* input,
    ara_buffer_t* output
);


// Add the new RGB preprocessing API
ARA_API ara_status_t ara_preprocess_rgb_to_model_input(
    ara_context_t ctx,
    const ara_buffer_t* input,
    ara_buffer_t* output
);

/**
 * Get required output buffer size for preprocessing
 * @param ctx Preprocessing context
 * @param output_size Output size in bytes
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_preprocess_get_output_size(
    ara_context_t ctx,
    size_t* output_size
);

/**
 * Get output dimensions for preprocessing
 * @param ctx Preprocessing context
 * @param width Output width
 * @param height Output height
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_preprocess_get_output_dims(
    ara_context_t ctx,
    int* width,
    int* height
);

/**
 * Cleanup preprocessing context
 * @param ctx Context to cleanup
 */
ARA_API void ara_preprocess_cleanup(ara_context_t ctx);

/* ============================================================
 * Inference API
 * ============================================================ */

typedef struct {
    const char* socket_path;      // Unix socket or TCP address
    const char* model_path;       // Path to model file
    int stream_id;                // Stream identifier
    bool use_shared_memory;       // Enable shared memory optimization
    const char* shm_path;         // Shared memory file path (if use_shared_memory=true)
    size_t shm_size_mb;           // Shared memory size in MB
    int endpoint_index;           // Which endpoint to use (0-based)
    int endpoint_group;           // Endpoint group (0=all, 1=pcie, 2=usb)
    bool enable_thread_safety;    // Enable mutex protection (default: true)
    int max_concurrent_requests;  // Max concurrent async requests (default: 4)
} ara_inference_config_t;

/**
 * Get input buffer size
 * @param ctx Inference context
 * @param input_size Output input size in bytes
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_inference_get_input_size(
    ara_context_t ctx,
    size_t* input_size
);

/**
 * Initialize inference context
 * Pre-allocates buffers for optimal performance.
 * Thread-safe if enable_thread_safety=true.
 * @param config Inference configuration
 * @param ctx Output context handle
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_inference_init(
    const ara_inference_config_t* config,
    ara_context_t* ctx
);

/**
 * Run synchronous inference
 * Thread-safe if configured.
 * @param ctx Inference context
 * @param input Input buffer
 * @param outputs Array of output buffers (allocated by caller)
 * @param num_outputs Number of output buffers
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_inference_run(
    ara_context_t ctx,
    const ara_buffer_t* input,
    ara_buffer_t* outputs,
    int num_outputs
);

/**
 * Run asynchronous inference
 * Thread-safe if configured.
 * @param ctx Inference context
 * @param input Input buffer
 * @param request_handle Output request handle for waiting
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_inference_async(
    ara_context_t ctx,
    const ara_buffer_t* input,
    void** request_handle
);

/**
 * Wait for inference completion
 * Thread-safe if configured.
 * @param ctx Inference context
 * @param request_handle Request handle from ara_inference_async
 * @param outputs Array of output buffers (allocated by caller)
 * @param num_outputs Number of output buffers
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_inference_wait(
    ara_context_t ctx,
    void* request_handle,
    ara_buffer_t* outputs,
    int num_outputs
);

/**
 * Get output buffer sizes
 * @param ctx Inference context
 * @param output_sizes Array to store output sizes
 * @param num_outputs Number of outputs
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_inference_get_output_sizes(
    ara_context_t ctx,
    size_t* output_sizes,
    int* num_outputs
);

/**
 * Allocate buffer in shared memory (if enabled)
 * @param ctx Inference context
 * @param size Size in bytes to allocate
 * @param buffer Output buffer pointer
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_inference_alloc_buffer(
    ara_context_t ctx,
    size_t size,
    void** buffer
);

/**
 * Free buffer allocated with ara_inference_alloc_buffer
 * @param ctx Inference context
 * @param buffer Buffer to free
 */
ARA_API void ara_inference_free_buffer(
    ara_context_t ctx,
    void* buffer
);

/**
 * Cleanup inference context
 * Frees all pre-allocated buffers.
 * @param ctx Context to cleanup
 */
ARA_API void ara_inference_cleanup(ara_context_t ctx);

/* ============================================================
 * Postprocessing API - Detection
 * ============================================================ */

typedef struct {
    float xmin;
    float ymin;
    float xmax;
    float ymax;
    float confidence;
    int class_id;
    const char* class_name;
} ara_detection_t;

typedef struct {
    ara_detection_t* detections;
    size_t num_detections;
    size_t max_detections;
} ara_detection_result_t;

/* ============================================================
 * Postprocessing API - Pose Estimation
 * ============================================================ */

typedef struct {
    float x;
    float y;
    float confidence;
} ara_keypoint_t;

typedef struct {
    ara_keypoint_t* keypoints;
    int num_keypoints;
    float bbox_xmin;
    float bbox_ymin;
    float bbox_xmax;
    float bbox_ymax;
    float confidence;
} ara_pose_t;

typedef struct {
    ara_pose_t* poses;
    size_t num_poses;
    size_t max_poses;
} ara_pose_result_t;

/* ============================================================
 * Postprocessing API - Segmentation
 * ============================================================ */

typedef struct {
    unsigned char* mask;     // Per-pixel class IDs
    int width;
    int height;
    int num_classes;
} ara_segmentation_result_t;

/* ============================================================
 * Postprocessing API - Unified Interface
 * ============================================================ */

/**
 * Initialize postprocessing context
 * Thread-safe after initialization.
 * @param model_path Path to model file
 * @param model_type Type of model
 * @param ctx Output context handle
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_postprocess_init(
    const char* model_path,
    ara_model_type_t model_type,
    ara_context_t* ctx
);

/**
 * Run YOLOv8 detection postprocessing
 * Optimized NMS algorithm with O(n²) but minimal memory operations.
 * @param ctx Postprocessing context
 * @param outputs Array of output buffers from inference
 * @param num_outputs Number of output buffers
 * @param orig_width Original image width
 * @param orig_height Original image height
 * @param score_threshold Score threshold for filtering
 * @param iou_threshold IOU threshold for NMS
 * @param result Output detection results (allocated by callee)
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_postprocess_yolov8(
    ara_context_t ctx,
    const ara_buffer_t* outputs,
    int num_outputs,
    int orig_width,
    int orig_height,
    float score_threshold,
    float iou_threshold,
    ara_detection_result_t** result
);

/**
 * Run pose estimation postprocessing
 * @param ctx Postprocessing context
 * @param outputs Array of output buffers from inference
 * @param num_outputs Number of output buffers
 * @param orig_width Original image width
 * @param orig_height Original image height
 * @param score_threshold Score threshold for filtering
 * @param result Output pose results (allocated by callee)
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_postprocess_pose(
    ara_context_t ctx,
    const ara_buffer_t* outputs,
    int num_outputs,
    int orig_width,
    int orig_height,
    float score_threshold,
    ara_pose_result_t** result
);

/**
 * Run segmentation postprocessing
 * @param ctx Postprocessing context
 * @param outputs Array of output buffers from inference
 * @param num_outputs Number of output buffers
 * @param orig_width Original image width
 * @param orig_height Original image height
 * @param result Output segmentation results (allocated by callee)
 * @return ARA_VISION_SUCCESS on success
 */
ARA_API ara_status_t ara_postprocess_segmentation(
    ara_context_t ctx,
    const ara_buffer_t* outputs,
    int num_outputs,
    int orig_width,
    int orig_height,
    ara_segmentation_result_t** result
);

/**
 * Free detection results
 * @param result Detection results to free
 */
ARA_API void ara_postprocess_free_detection_results(ara_detection_result_t* result);

/**
 * Free pose results
 * @param result Pose results to free
 */
ARA_API void ara_postprocess_free_pose_results(ara_pose_result_t* result);

/**
 * Free segmentation results
 * @param result Segmentation results to free
 */
ARA_API void ara_postprocess_free_segmentation_results(ara_segmentation_result_t* result);

/**
 * Cleanup postprocessing context
 * @param ctx Context to cleanup
 */
ARA_API void ara_postprocess_cleanup(ara_context_t ctx);

#ifdef __cplusplus
}
#endif

#endif /* ARA_VISION_INFERENCE_API_H */
