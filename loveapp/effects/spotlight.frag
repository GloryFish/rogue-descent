// 
//  spotlight.frag
//  rogue-descent
//  
//  Created by Jay Roberts on 2012-04-27.
//  Copyright 2012 GloryFish.org. All rights reserved.
// 

extern vec2 focus;
extern vec2 textureSize;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
  focus;
  textureSize;
  
  vec4 original = Texel(texture, texture_coords);
  vec2 position = vec2(focus.x, (textureSize.y - focus.y));
  float radius = 200.0;
  
  float dist = distance(position, pixel_coords);
  
  float lum = 1.2 - (dist / 600);
  
  return vec4(original.rgb * lum, original.a); 
}