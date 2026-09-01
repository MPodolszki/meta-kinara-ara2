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
#include <vector>

#include "common_types.h"
#include "core_api.h"

namespace ara::ep {

/**
 * @brief Interface to execute inference using the Kinara runtime.
 *
 * This class encapsulates interaction with the runtime for loading a model,
 * running inference, and retrieving output shapes.
 */
class CORE_API Runner {
 public:
  /**
   * @brief Construct a Runner instance.
   */
  Runner();

  // Prevent copy construction and assignment
  Runner(const Runner&) = delete;
  Runner& operator=(const Runner&) = delete;

  // Allow move construction and assignment
  Runner(Runner&&) noexcept;
  Runner& operator=(Runner&&) noexcept;

  /**
   * @brief Initialize the runner with a compiled model and options.
   *
   * @param ara_model Binary model data and size.
   * @param provider_opts_map ort execution provider map for ara2 ep
   * @param runner_opts Runtime configuration options.
   * @return Status code indicating success or error reason.
   */
  AraRunnerStatusCode Init(
      const ARABinaryContext& ara_model,
      const std::unordered_map<std::string, std::string>& provides_opts_map,
      const AraRunnerOptions& runner_opts);

  /**
   * @brief Execute inference using the provided inputs and populate outputs.
   *
   * @param inputs Vector of input tensors with populated data.
   * @param outputs Vector of output tensors with allocated buffers.
   * @return Status code indicating inference result.
   */
  AraRunnerStatusCode Compute(const AraRunnerTensors& inputs,
                              AraRunnerTensors& outputs);

  /**
   * @brief Get the shape of the i-th output tensor.
   *
   * @param i Index of the output tensor.
   * @return Shape vector of the specified output tensor.
   */
  std::vector<int64_t> GetOutputDim(int i) const;

  /**
   * @brief Api to get log line if an error status is received from runner
   *
   * @param st status code received from runner interface apis
   * @return string literal pointer elaborating error message
   */
  static const char* AraRunnerErrorLogging(const AraRunnerStatusCode st);

  /**
   * @brief Destroy the runner and clean up all resources.
   */
  ~Runner();

 private:
  class Impl;  ///< Forward-declared implementation
  std::unique_ptr<Impl>
      pImpl;  ///< Implementation pointer to hide implementation details
};

}  // namespace ara::ep
