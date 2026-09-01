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

#include <string>
#include <unordered_set>

#include "common_types.h"
#include "core_api.h"

namespace onnxruntime {
class GraphViewer;  // Forward declaration
#ifdef BUILD_ARA_EP_STATIC_LIB
class Node;
#else
struct Node;
#endif
}  // namespace onnxruntime

namespace ara {
namespace ep {

/**
 * @class Core
 * @brief Core class responsible for compiling and interacting with ARA
 * execution provider.
 */
class CORE_API Core {
 public:
  /**
   * @brief Default constructor.
   */
  Core();

  /**
   * @brief Constructor with configuration.
   * @param config_map Configuration options as key-value pairs.
   */
  Core(const std::unordered_map<std::string, std::string>& input_config_map);

  /**
   * @brief Destructor.
   */
  ~Core();

  /**
   * @brief Retrieves a list of supported operators for the model at the given
   * path.
   * @param full_model_path Full file path to the model.
   * @param graph_viewer Reference to the graph viewer for the subgraph.
   * @return Unordered set of pointers to ONNX Runtime nodes that are supported
   * by the ARA Compiler.
   */
  std::unordered_set<const onnxruntime::Node*> GetSupportedNodes(
      const std::string& full_model_path,
      const onnxruntime::GraphViewer& graph_viewer) const;

  /**
   * @brief Compiles a subgraph into an ARABinaryContext using DVRunner.
   * @param submodel_path File path to the submodel to compile.
   * @param graph_viewer Reference to the graph viewer for the subgraph.
   * @return Compiled ARABinaryContext object containing the binary data.
   */
  ARABinaryContext CompileSubgraph(
      const std::string& submodel_path,
      const onnxruntime::GraphViewer& graph_viewer);

 private:
  class Impl;                 /**< PIMPL idiom for implementation hiding */
  std::unique_ptr<Impl> impl; /**< Pointer to the implementation */
};

}  // namespace ep
}  // namespace ara
