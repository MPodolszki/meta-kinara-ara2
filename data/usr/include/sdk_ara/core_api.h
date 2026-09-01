/*
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

#pragma once

#if defined(_WIN32) || defined(__CYGWIN__)
#ifdef BUILDING_CORE_DLL
#define CORE_API __declspec(dllexport)
#elif defined(BUILD_ARA_EP_STATIC_LIB)
#define CORE_API  // static build - no dllimport
#else
#define CORE_API __declspec(dllimport)
#endif
#else
#if __GNUC__ >= 4
#define CORE_API __attribute__((visibility("default")))
#else
#define CORE_API
#endif
#endif
