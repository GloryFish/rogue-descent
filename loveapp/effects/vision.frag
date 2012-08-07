const float exposure = 0.7;
const vec4 lumacoeff = vec4(0.212671, 0.715160, 0.072169, 0.0);

extern vec2 focus;
extern vec2 textureSize;
extern Image saturationMap;


vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  // Calculate focus position
  vec2 focus_position = vec2(focus.x, (textureSize.y - focus.y));

  vec4 input_texel = Texel(texture, texture_coords);

  float luminance = dot(input_texel, lumacoeff);

  vec4 greyscale_texel = vec4(vec4(luminance).rgb, 1.0);

  float saturation = dot(Texel(saturationMap, texture_coords), lumacoeff);

  return mix(greyscale_texel, input_texel, saturation);
}
