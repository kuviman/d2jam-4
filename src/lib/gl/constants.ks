# ClearBufferMask
const DEPTH_BUFFER_BIT :: GLenum = 0x00000100;
const STENCIL_BUFFER_BIT :: GLenum = 0x00000400;
const COLOR_BUFFER_BIT :: GLenum = 0x00004000;

# BeginMode
const POINTS :: GLenum = 0x0000;
const LINES :: GLenum = 0x0001;
const LINE_LOOP :: GLenum = 0x0002;
const LINE_STRIP :: GLenum = 0x0003;
const TRIANGLES :: GLenum = 0x0004;
const TRIANGLE_STRIP :: GLenum = 0x0005;
const TRIANGLE_FAN :: GLenum = 0x0006;

# BlendingFactorDest
const ZERO :: GLenum = 0;
const ONE :: GLenum = 1;
const SRC_COLOR :: GLenum = 0x0300;
const ONE_MINUS_SRC_COLOR :: GLenum = 0x0301;
const SRC_ALPHA :: GLenum = 0x0302;
const ONE_MINUS_SRC_ALPHA :: GLenum = 0x0303;
const DST_ALPHA :: GLenum = 0x0304;
const ONE_MINUS_DST_ALPHA :: GLenum = 0x0305;

# BlendingFactorSrc
#      ZERO
#      ONE
const DST_COLOR :: GLenum = 0x0306;
const ONE_MINUS_DST_COLOR :: GLenum = 0x0307;
const SRC_ALPHA_SATURATE :: GLenum = 0x0308;
#      SRC_ALPHA
#      ONE_MINUS_SRC_ALPHA
#      DST_ALPHA
#      ONE_MINUS_DST_ALPHA
# BlendEquationSeparate
const FUNC_ADD :: GLenum = 0x8006;
const BLEND_EQUATION :: GLenum = 0x8009;
const BLEND_EQUATION_RGB :: GLenum = 0x8009;
# same as BLEND_EQUATION
const BLEND_EQUATION_ALPHA :: GLenum = 0x883D;

# BlendSubtract
const FUNC_SUBTRACT :: GLenum = 0x800A;
const FUNC_REVERSE_SUBTRACT :: GLenum = 0x800B;

# Separate Blend Functions
const BLEND_DST_RGB :: GLenum = 0x80C8;
const BLEND_SRC_RGB :: GLenum = 0x80C9;
const BLEND_DST_ALPHA :: GLenum = 0x80CA;
const BLEND_SRC_ALPHA :: GLenum = 0x80CB;
const CONSTANT_COLOR :: GLenum = 0x8001;
const ONE_MINUS_CONSTANT_COLOR :: GLenum = 0x8002;
const CONSTANT_ALPHA :: GLenum = 0x8003;
const ONE_MINUS_CONSTANT_ALPHA :: GLenum = 0x8004;
const BLEND_COLOR :: GLenum = 0x8005;

# Buffer Objects
const ARRAY_BUFFER :: GLenum = 0x8892;
const ELEMENT_ARRAY_BUFFER :: GLenum = 0x8893;
const ARRAY_BUFFER_BINDING :: GLenum = 0x8894;
const ELEMENT_ARRAY_BUFFER_BINDING :: GLenum = 0x8895;

const STREAM_DRAW :: GLenum = 0x88E0;
const STATIC_DRAW :: GLenum = 0x88E4;
const DYNAMIC_DRAW :: GLenum = 0x88E8;

const BUFFER_SIZE :: GLenum = 0x8764;
const BUFFER_USAGE :: GLenum = 0x8765;

const CURRENT_VERTEX_ATTRIB :: GLenum = 0x8626;

# CullFaceMode
const FRONT :: GLenum = 0x0404;
const BACK :: GLenum = 0x0405;
const FRONT_AND_BACK :: GLenum = 0x0408;

# DepthFunction
#      NEVER
#      LESS
#      EQUAL
#      LEQUAL
#      GREATER
#      NOTEQUAL
#      GEQUAL
#      ALWAYS
# EnableCap
# TEXTURE_2D
const CULL_FACE :: GLenum = 0x0B44;
const BLEND :: GLenum = 0x0BE2;
const DITHER :: GLenum = 0x0BD0;
const STENCIL_TEST :: GLenum = 0x0B90;
const DEPTH_TEST :: GLenum = 0x0B71;
const SCISSOR_TEST :: GLenum = 0x0C11;
const POLYGON_OFFSET_FILL :: GLenum = 0x8037;
const SAMPLE_ALPHA_TO_COVERAGE :: GLenum = 0x809E;
const SAMPLE_COVERAGE :: GLenum = 0x80A0;

# ErrorCode
const NO_ERROR :: GLenum = 0;
const INVALID_ENUM :: GLenum = 0x0500;
const INVALID_VALUE :: GLenum = 0x0501;
const INVALID_OPERATION :: GLenum = 0x0502;
const OUT_OF_MEMORY :: GLenum = 0x0505;

# FrontFaceDirection
const CW :: GLenum = 0x0900;
const CCW :: GLenum = 0x0901;

# GetPName
const LINE_WIDTH :: GLenum = 0x0B21;
const ALIASED_POINT_SIZE_RANGE :: GLenum = 0x846D;
const ALIASED_LINE_WIDTH_RANGE :: GLenum = 0x846E;
const CULL_FACE_MODE :: GLenum = 0x0B45;
const FRONT_FACE :: GLenum = 0x0B46;
const DEPTH_RANGE :: GLenum = 0x0B70;
const DEPTH_WRITEMASK :: GLenum = 0x0B72;
const DEPTH_CLEAR_VALUE :: GLenum = 0x0B73;
const DEPTH_FUNC :: GLenum = 0x0B74;
const STENCIL_CLEAR_VALUE :: GLenum = 0x0B91;
const STENCIL_FUNC :: GLenum = 0x0B92;
const STENCIL_FAIL :: GLenum = 0x0B94;
const STENCIL_PASS_DEPTH_FAIL :: GLenum = 0x0B95;
const STENCIL_PASS_DEPTH_PASS :: GLenum = 0x0B96;
const STENCIL_REF :: GLenum = 0x0B97;
const STENCIL_VALUE_MASK :: GLenum = 0x0B93;
const STENCIL_WRITEMASK :: GLenum = 0x0B98;
const STENCIL_BACK_FUNC :: GLenum = 0x8800;
const STENCIL_BACK_FAIL :: GLenum = 0x8801;
const STENCIL_BACK_PASS_DEPTH_FAIL :: GLenum = 0x8802;
const STENCIL_BACK_PASS_DEPTH_PASS :: GLenum = 0x8803;
const STENCIL_BACK_REF :: GLenum = 0x8CA3;
const STENCIL_BACK_VALUE_MASK :: GLenum = 0x8CA4;
const STENCIL_BACK_WRITEMASK :: GLenum = 0x8CA5;
const VIEWPORT :: GLenum = 0x0BA2;
const SCISSOR_BOX :: GLenum = 0x0C10;
#      SCISSOR_TEST
const COLOR_CLEAR_VALUE :: GLenum = 0x0C22;
const COLOR_WRITEMASK :: GLenum = 0x0C23;
const UNPACK_ALIGNMENT :: GLenum = 0x0CF5;
const PACK_ALIGNMENT :: GLenum = 0x0D05;
const MAX_TEXTURE_SIZE :: GLenum = 0x0D33;
const MAX_VIEWPORT_DIMS :: GLenum = 0x0D3A;
const SUBPIXEL_BITS :: GLenum = 0x0D50;
const RED_BITS :: GLenum = 0x0D52;
const GREEN_BITS :: GLenum = 0x0D53;
const BLUE_BITS :: GLenum = 0x0D54;
const ALPHA_BITS :: GLenum = 0x0D55;
const DEPTH_BITS :: GLenum = 0x0D56;
const STENCIL_BITS :: GLenum = 0x0D57;
const POLYGON_OFFSET_UNITS :: GLenum = 0x2A00;
#      POLYGON_OFFSET_FILL
const POLYGON_OFFSET_FACTOR :: GLenum = 0x8038;
const TEXTURE_BINDING_2D :: GLenum = 0x8069;
const SAMPLE_BUFFERS :: GLenum = 0x80A8;
const SAMPLES :: GLenum = 0x80A9;
const SAMPLE_COVERAGE_VALUE :: GLenum = 0x80AA;
const SAMPLE_COVERAGE_INVERT :: GLenum = 0x80AB;

# GetTextureParameter
#      TEXTURE_MAG_FILTER
#      TEXTURE_MIN_FILTER
#      TEXTURE_WRAP_S
#      TEXTURE_WRAP_T
const COMPRESSED_TEXTURE_FORMATS :: GLenum = 0x86A3;

# HintMode
const DONT_CARE :: GLenum = 0x1100;
const FASTEST :: GLenum = 0x1101;
const NICEST :: GLenum = 0x1102;

# HintTarget
const GENERATE_MIPMAP_HINT :: GLenum = 0x8192;

# DataType
const BYTE :: GLenum = 0x1400;
const UNSIGNED_BYTE :: GLenum = 0x1401;
const SHORT :: GLenum = 0x1402;
const UNSIGNED_SHORT :: GLenum = 0x1403;
const INT :: GLenum = 0x1404;
const UNSIGNED_INT :: GLenum = 0x1405;
const FLOAT :: GLenum = 0x1406;

# PixelFormat
const DEPTH_COMPONENT :: GLenum = 0x1902;
const ALPHA :: GLenum = 0x1906;
const RGB :: GLenum = 0x1907;
const RGBA :: GLenum = 0x1908;
const LUMINANCE :: GLenum = 0x1909;
const LUMINANCE_ALPHA :: GLenum = 0x190A;

# PixelType
#      UNSIGNED_BYTE
const UNSIGNED_SHORT_4_4_4_4 :: GLenum = 0x8033;
const UNSIGNED_SHORT_5_5_5_1 :: GLenum = 0x8034;
const UNSIGNED_SHORT_5_6_5 :: GLenum = 0x8363;

# Shaders
const FRAGMENT_SHADER :: GLenum = 0x8B30;
const VERTEX_SHADER :: GLenum = 0x8B31;
const MAX_VERTEX_ATTRIBS :: GLenum = 0x8869;
const MAX_VERTEX_UNIFORM_VECTORS :: GLenum = 0x8DFB;
const MAX_VARYING_VECTORS :: GLenum = 0x8DFC;
const MAX_COMBINED_TEXTURE_IMAGE_UNITS :: GLenum = 0x8B4D;
const MAX_VERTEX_TEXTURE_IMAGE_UNITS :: GLenum = 0x8B4C;
const MAX_TEXTURE_IMAGE_UNITS :: GLenum = 0x8872;
const MAX_FRAGMENT_UNIFORM_VECTORS :: GLenum = 0x8DFD;
const SHADER_TYPE :: GLenum = 0x8B4F;
const DELETE_STATUS :: GLenum = 0x8B80;
const LINK_STATUS :: GLenum = 0x8B82;
const VALIDATE_STATUS :: GLenum = 0x8B83;
const ATTACHED_SHADERS :: GLenum = 0x8B85;
const ACTIVE_UNIFORMS :: GLenum = 0x8B86;
const ACTIVE_ATTRIBUTES :: GLenum = 0x8B89;
const SHADING_LANGUAGE_VERSION :: GLenum = 0x8B8C;
const CURRENT_PROGRAM :: GLenum = 0x8B8D;

# StencilFunction
const NEVER :: GLenum = 0x0200;
const LESS :: GLenum = 0x0201;
const EQUAL :: GLenum = 0x0202;
const LEQUAL :: GLenum = 0x0203;
const GREATER :: GLenum = 0x0204;
const NOTEQUAL :: GLenum = 0x0205;
const GEQUAL :: GLenum = 0x0206;
const ALWAYS :: GLenum = 0x0207;

# StencilOp
#      ZERO
const KEEP :: GLenum = 0x1E00;
const REPLACE :: GLenum = 0x1E01;
const INCR :: GLenum = 0x1E02;
const DECR :: GLenum = 0x1E03;
const INVERT :: GLenum = 0x150A;
const INCR_WRAP :: GLenum = 0x8507;
const DECR_WRAP :: GLenum = 0x8508;

# StringName
const VENDOR :: GLenum = 0x1F00;
const RENDERER :: GLenum = 0x1F01;
const VERSION :: GLenum = 0x1F02;

# TextureMagFilter
const NEAREST :: GLenum = 0x2600;
const LINEAR :: GLenum = 0x2601;

# TextureMinFilter
#      NEAREST
#      LINEAR
const NEAREST_MIPMAP_NEAREST :: GLenum = 0x2700;
const LINEAR_MIPMAP_NEAREST :: GLenum = 0x2701;
const NEAREST_MIPMAP_LINEAR :: GLenum = 0x2702;
const LINEAR_MIPMAP_LINEAR :: GLenum = 0x2703;

# TextureParameterName
const TEXTURE_MAG_FILTER :: GLenum = 0x2800;
const TEXTURE_MIN_FILTER :: GLenum = 0x2801;
const TEXTURE_WRAP_S :: GLenum = 0x2802;
const TEXTURE_WRAP_T :: GLenum = 0x2803;

# TextureTarget
const TEXTURE_2D :: GLenum = 0x0DE1;
const TEXTURE :: GLenum = 0x1702;

const TEXTURE_CUBE_MAP :: GLenum = 0x8513;
const TEXTURE_BINDING_CUBE_MAP :: GLenum = 0x8514;
const TEXTURE_CUBE_MAP_POSITIVE_X :: GLenum = 0x8515;
const TEXTURE_CUBE_MAP_NEGATIVE_X :: GLenum = 0x8516;
const TEXTURE_CUBE_MAP_POSITIVE_Y :: GLenum = 0x8517;
const TEXTURE_CUBE_MAP_NEGATIVE_Y :: GLenum = 0x8518;
const TEXTURE_CUBE_MAP_POSITIVE_Z :: GLenum = 0x8519;
const TEXTURE_CUBE_MAP_NEGATIVE_Z :: GLenum = 0x851A;
const MAX_CUBE_MAP_TEXTURE_SIZE :: GLenum = 0x851C;

# TextureUnit
const TEXTURE0 :: GLenum = 0x84C0;
const TEXTURE1 :: GLenum = 0x84C1;
const TEXTURE2 :: GLenum = 0x84C2;
const TEXTURE3 :: GLenum = 0x84C3;
const TEXTURE4 :: GLenum = 0x84C4;
const TEXTURE5 :: GLenum = 0x84C5;
const TEXTURE6 :: GLenum = 0x84C6;
const TEXTURE7 :: GLenum = 0x84C7;
const TEXTURE8 :: GLenum = 0x84C8;
const TEXTURE9 :: GLenum = 0x84C9;
const TEXTURE10 :: GLenum = 0x84CA;
const TEXTURE11 :: GLenum = 0x84CB;
const TEXTURE12 :: GLenum = 0x84CC;
const TEXTURE13 :: GLenum = 0x84CD;
const TEXTURE14 :: GLenum = 0x84CE;
const TEXTURE15 :: GLenum = 0x84CF;
const TEXTURE16 :: GLenum = 0x84D0;
const TEXTURE17 :: GLenum = 0x84D1;
const TEXTURE18 :: GLenum = 0x84D2;
const TEXTURE19 :: GLenum = 0x84D3;
const TEXTURE20 :: GLenum = 0x84D4;
const TEXTURE21 :: GLenum = 0x84D5;
const TEXTURE22 :: GLenum = 0x84D6;
const TEXTURE23 :: GLenum = 0x84D7;
const TEXTURE24 :: GLenum = 0x84D8;
const TEXTURE25 :: GLenum = 0x84D9;
const TEXTURE26 :: GLenum = 0x84DA;
const TEXTURE27 :: GLenum = 0x84DB;
const TEXTURE28 :: GLenum = 0x84DC;
const TEXTURE29 :: GLenum = 0x84DD;
const TEXTURE30 :: GLenum = 0x84DE;
const TEXTURE31 :: GLenum = 0x84DF;
const ACTIVE_TEXTURE :: GLenum = 0x84E0;

# TextureWrapMode
const REPEAT :: GLenum = 0x2901;
const CLAMP_TO_EDGE :: GLenum = 0x812F;
const MIRRORED_REPEAT :: GLenum = 0x8370;

# Uniform Types
const FLOAT_VEC2 :: GLenum = 0x8B50;
const FLOAT_VEC3 :: GLenum = 0x8B51;
const FLOAT_VEC4 :: GLenum = 0x8B52;
const INT_VEC2 :: GLenum = 0x8B53;
const INT_VEC3 :: GLenum = 0x8B54;
const INT_VEC4 :: GLenum = 0x8B55;
const BOOL :: GLenum = 0x8B56;
const BOOL_VEC2 :: GLenum = 0x8B57;
const BOOL_VEC3 :: GLenum = 0x8B58;
const BOOL_VEC4 :: GLenum = 0x8B59;
const FLOAT_MAT2 :: GLenum = 0x8B5A;
const FLOAT_MAT3 :: GLenum = 0x8B5B;
const FLOAT_MAT4 :: GLenum = 0x8B5C;
const SAMPLER_2D :: GLenum = 0x8B5E;
const SAMPLER_CUBE :: GLenum = 0x8B60;

# Vertex Arrays
const VERTEX_ATTRIB_ARRAY_ENABLED :: GLenum = 0x8622;
const VERTEX_ATTRIB_ARRAY_SIZE :: GLenum = 0x8623;
const VERTEX_ATTRIB_ARRAY_STRIDE :: GLenum = 0x8624;
const VERTEX_ATTRIB_ARRAY_TYPE :: GLenum = 0x8625;
const VERTEX_ATTRIB_ARRAY_NORMALIZED :: GLenum = 0x886A;
const VERTEX_ATTRIB_ARRAY_POINTER :: GLenum = 0x8645;
const VERTEX_ATTRIB_ARRAY_BUFFER_BINDING :: GLenum = 0x889F;

# Read Format
const IMPLEMENTATION_COLOR_READ_TYPE :: GLenum = 0x8B9A;
const IMPLEMENTATION_COLOR_READ_FORMAT :: GLenum = 0x8B9B;

# Shader Source
const COMPILE_STATUS :: GLenum = 0x8B81;

# Shader Precision-Specified Types
const LOW_FLOAT :: GLenum = 0x8DF0;
const MEDIUM_FLOAT :: GLenum = 0x8DF1;
const HIGH_FLOAT :: GLenum = 0x8DF2;
const LOW_INT :: GLenum = 0x8DF3;
const MEDIUM_INT :: GLenum = 0x8DF4;
const HIGH_INT :: GLenum = 0x8DF5;

# Framebuffer Object.
const FRAMEBUFFER :: GLenum = 0x8D40;
const RENDERBUFFER :: GLenum = 0x8D41;

const RGBA4 :: GLenum = 0x8056;
const RGB5_A1 :: GLenum = 0x8057;
const RGBA8 :: GLenum = 0x8058;
const RGB565 :: GLenum = 0x8D62;
const DEPTH_COMPONENT16 :: GLenum = 0x81A5;
const STENCIL_INDEX8 :: GLenum = 0x8D48;
const DEPTH_STENCIL :: GLenum = 0x84F9;

const RENDERBUFFER_WIDTH :: GLenum = 0x8D42;
const RENDERBUFFER_HEIGHT :: GLenum = 0x8D43;
const RENDERBUFFER_INTERNAL_FORMAT :: GLenum = 0x8D44;
const RENDERBUFFER_RED_SIZE :: GLenum = 0x8D50;
const RENDERBUFFER_GREEN_SIZE :: GLenum = 0x8D51;
const RENDERBUFFER_BLUE_SIZE :: GLenum = 0x8D52;
const RENDERBUFFER_ALPHA_SIZE :: GLenum = 0x8D53;
const RENDERBUFFER_DEPTH_SIZE :: GLenum = 0x8D54;
const RENDERBUFFER_STENCIL_SIZE :: GLenum = 0x8D55;

const FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE :: GLenum = 0x8CD0;
const FRAMEBUFFER_ATTACHMENT_OBJECT_NAME :: GLenum = 0x8CD1;
const FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL :: GLenum = 0x8CD2;
const FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE :: GLenum = 0x8CD3;

const COLOR_ATTACHMENT0 :: GLenum = 0x8CE0;
const DEPTH_ATTACHMENT :: GLenum = 0x8D00;
const STENCIL_ATTACHMENT :: GLenum = 0x8D20;
const DEPTH_STENCIL_ATTACHMENT :: GLenum = 0x821A;

const NONE :: GLenum = 0;

const FRAMEBUFFER_COMPLETE :: GLenum = 0x8CD5;
const FRAMEBUFFER_INCOMPLETE_ATTACHMENT :: GLenum = 0x8CD6;
const FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT :: GLenum = 0x8CD7;
const FRAMEBUFFER_INCOMPLETE_DIMENSIONS :: GLenum = 0x8CD9;
const FRAMEBUFFER_UNSUPPORTED :: GLenum = 0x8CDD;

const FRAMEBUFFER_BINDING :: GLenum = 0x8CA6;
const RENDERBUFFER_BINDING :: GLenum = 0x8CA7;
const MAX_RENDERBUFFER_SIZE :: GLenum = 0x84E8;

const INVALID_FRAMEBUFFER_OPERATION :: GLenum = 0x0506;

# WebGL-specific enums
const UNPACK_FLIP_Y_WEBGL :: GLenum = 0x9240;
const UNPACK_PREMULTIPLY_ALPHA_WEBGL :: GLenum = 0x9241;
const CONTEXT_LOST_WEBGL :: GLenum = 0x9242;
const UNPACK_COLORSPACE_CONVERSION_WEBGL :: GLenum = 0x9243;
const BROWSER_DEFAULT_WEBGL :: GLenum = 0x9244;
