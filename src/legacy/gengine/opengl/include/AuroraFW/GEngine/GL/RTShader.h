/*****************************************************************************
**                                    / _|
**   __ _ _   _ _ __ ___  _ __ __ _  | |_ ___  ___ ___
**  / _` | | | | '__/ _ \| '__/ _` | |  _/ _ \/ __/ __|
** | (_| | |_| | | | (_) | | | (_| | | || (_) \__ \__ \
**  \__,_|\__,_|_|  \___/|_|  \__,_| |_| \___/|___/___/
**
** Copyright (C) 2018 Aurora Free Open Source Software.
**
** This file is part of the Aurora Free Open Source Software. This
** organization promote free and open source software that you can
** redistribute and/or modify under the terms of the GNU Lesser General
** Public License Version 3 as published by the Free Software Foundation or
** (at your option) any later version approved by the Aurora Free Open Source
** Software Organization. The license is available in the package root path
** as 'LICENSE' file. Please review the following information to ensure the
** GNU Lesser General Public License version 3 requirements will be met:
** https://www.gnu.org/licenses/lgpl.html .
**
** Alternatively, this file may be used under the terms of the GNU General
** Public License version 3 or later as published by the Free Software
** Foundation. Please review the following information to ensure the GNU
** General Public License requirements will be met:
** http://www.gnu.org/licenses/gpl-3.0.html.
**
** NOTE: All products, services or anything associated to trademarks and
** service marks used or referenced on this file are the property of their
** respective companies/owners or its subsidiaries. Other names and brands
** may be claimed as the property of others.
**
** For more info about intellectual property visit: aurorafoss.org or
** directly send an email to: contact (at) aurorafoss.org .
*****************************************************************************/

#ifndef AURORAFW_GENGINE_GL_RTSHADER_H
#define AURORAFW_GENGINE_GL_RTSHADER_H

#include <AuroraFW/Global.h>
#include <AuroraFW/GEngine/GL/Global.h>

#include <AuroraFW/STDL/STL/String.h>
#include <AuroraFW/GEngine/API/RTShader.h>

namespace AuroraFW::GEngine::API {
	class GLRTShaderPipeline;

	class AFW_API GLRTShader : public RTShader
	{
	friend GLRTShaderPipeline;
	public:
		enum class GLParameter : GLenum {
			Type = GL_SHADER_TYPE,
			DeleteStatus = GL_DELETE_STATUS,
			CompileStatus = GL_COMPILE_STATUS,
			LogLength = GL_INFO_LOG_LENGTH,
			SourceLength = GL_SHADER_SOURCE_LENGTH
		};

		enum class GLType : GLenum {
			Unknown = 0x31,
			Cached = 0x32,
			Vertex = 0x1,
			Fragment = 0x2,
			Geometry = 0x4,
			TessellationControl = 0x8,
			TessellationEvaluation = 0x10,
			Compute = 0x20
		};

		GLRTShader(Shader::Type);
		~GLRTShader();

		static GLuint importCachedSourceFileShader(std::string );
		static GLuint importCachedSourceFileShader(const char* );
		static GLuint compileShaderFromSource(std::string& );
		static GLuint compileShaderFromSource(const char* );
		static GLuint compileShaderFromFile(std::string );
		static GLuint compileShaderFromFile(const char* );
		static GLint getShaderInfo(GLuint, GLParameter );

		void importCachedFile(const std::string& ) override;
		void importCachedSource(std::string ) override;
		void compileFromSource(std::string ) override;
		void compileFromFile(const std::string& ) override;
		AFW_FORCE_INLINE bool isCompiled() const override { return _compiled; }

		GLuint getGLShader();
		GLint getGLInfo(GLParameter );

	private:
		void init();
		GLuint _shader;
		Shader::Type _type;
		GLint _compiled = GL_FALSE;
	};
}

#endif // AURORAFW_GENGINE_GL_RTSHADER_H