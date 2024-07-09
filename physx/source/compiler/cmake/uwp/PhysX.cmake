##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
##  * Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
##  * Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
##  * Neither the name of NVIDIA CORPORATION nor the names of its
##    contributors may be used to endorse or promote products derived
##    from this software without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ''AS IS'' AND ANY
## EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
## PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
## CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
## EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
## PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
## PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
## OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
## (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
## Copyright (c) 2008-2021 NVIDIA Corporation. All rights reserved.

#
# Build PhysX (PROJECT not SOLUTION)
#

SET(PHYSX_RESOURCE
	${PHYSX_SOURCE_DIR}/compiler/resource_${RESOURCE_LIBPATH_SUFFIX}/PhysX.rc
)
SOURCE_GROUP(resource FILES ${PHYSX_RESOURCE})

IF(PX_GENERATE_STATIC_LIBRARIES)
	SET(PHYSX_PLATFORM_OBJECT_FILES
		$<TARGET_OBJECTS:LowLevel>
		$<TARGET_OBJECTS:LowLevelAABB>
		$<TARGET_OBJECTS:LowLevelDynamics>
		$<TARGET_OBJECTS:PhysXTask>
		$<TARGET_OBJECTS:SceneQuery>
		$<TARGET_OBJECTS:SimulationController>
	)
ENDIF()

SET(PHYSX_PLATFORM_SRC_FILES
	${PHYSX_RESOURCE}

	${PHYSX_DEVICE_SOURCE}

	${PHYSX_UWP_SOURCE}

	${PHYSX_PLATFORM_OBJECT_FILES}
)

IF(NOT PX_GENERATE_STATIC_LIBRARIES)
	SET(PXPHYSX_LIBTYPE_DEFS
		PX_PHYSX_FOUNDATION_EXPORTS;PX_PHYSX_CORE_EXPORTS;
	)
ENDIF()

# Use generator expressions to set config specific preprocessor definitions
SET(PHYSX_COMPILE_DEFS
	# Common to all configurations
	${PHYSX_UWP_COMPILE_DEFS};${PXPHYSX_LIBTYPE_DEFS};${PHYSX_LIBTYPE_DEFS};

	$<$<CONFIG:debug>:${PHYSX_UWP_DEBUG_COMPILE_DEFS};>
	$<$<CONFIG:checked>:${PHYSX_UWP_CHECKED_COMPILE_DEFS};>
	$<$<CONFIG:profile>:${PHYSX_UWP_PROFILE_COMPILE_DEFS};>
	$<$<CONFIG:release>:${PHYSX_UWP_RELEASE_COMPILE_DEFS};>
)

IF(PX_GENERATE_STATIC_LIBRARIES)
	SET(PHYSX_LIBTYPE STATIC)
ELSE()
	SET(PHYSX_LIBTYPE SHARED)
ENDIF()

IF(NOT PX_GENERATE_STATIC_LIBRARIES)
	SET(PHYSX_PRIVATE_PLATFORM_LINKED_LIBS
			LowLevel LowLevelAABB LowLevelDynamics PhysXTask SceneQuery SimulationController
	)
ENDIF()

IF(NV_USE_GAMEWORKS_OUTPUT_DIRS AND PHYSX_LIBTYPE STREQUAL "STATIC")
	SET(PHYSX_COMPILE_PDB_NAME_DEBUG "PhysX_static${CMAKE_DEBUG_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_CHECKED "PhysX_static${CMAKE_CHECKED_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_PROFILE "PhysX_static${CMAKE_PROFILE_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_RELEASE "PhysX_static${CMAKE_RELEASE_POSTFIX}")
ELSE()
	SET(PHYSX_COMPILE_PDB_NAME_DEBUG "PhysX${CMAKE_DEBUG_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_CHECKED "PhysX${CMAKE_CHECKED_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_PROFILE "PhysX${CMAKE_PROFILE_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_RELEASE "PhysX${CMAKE_RELEASE_POSTFIX}")
ENDIF()

IF(MSVC AND (PHYSX_LIBTYPE STREQUAL "SHARED"))
	INSTALL(FILES $<TARGET_PDB_FILE:PhysX>
		DESTINATION $<$<CONFIG:debug>:${PX_ROOT_LIB_DIR}/debug>$<$<CONFIG:release>:${PX_ROOT_LIB_DIR}/release>$<$<CONFIG:checked>:${PX_ROOT_LIB_DIR}/checked>$<$<CONFIG:profile>:${PX_ROOT_LIB_DIR}/profile> OPTIONAL)
ELSE()
	INSTALL(FILES ${PHYSX_ROOT_DIR}/$<$<CONFIG:debug>:${PX_ROOT_LIB_DIR}/debug>$<$<CONFIG:release>:${PX_ROOT_LIB_DIR}/release>$<$<CONFIG:checked>:${PX_ROOT_LIB_DIR}/checked>$<$<CONFIG:profile>:${PX_ROOT_LIB_DIR}/profile>/$<$<CONFIG:debug>:${PHYSX_COMPILE_PDB_NAME_DEBUG}>$<$<CONFIG:checked>:${PHYSX_COMPILE_PDB_NAME_CHECKED}>$<$<CONFIG:profile>:${PHYSX_COMPILE_PDB_NAME_PROFILE}>$<$<CONFIG:release>:${PHYSX_COMPILE_PDB_NAME_RELEASE}>.pdb
		DESTINATION $<$<CONFIG:debug>:${PX_ROOT_LIB_DIR}/debug>$<$<CONFIG:release>:${PX_ROOT_LIB_DIR}/release>$<$<CONFIG:checked>:${PX_ROOT_LIB_DIR}/checked>$<$<CONFIG:profile>:${PX_ROOT_LIB_DIR}/profile> OPTIONAL)
ENDIF()

SET(PHYSX_PLATFORM_LINK_FLAGS "/MAP")
