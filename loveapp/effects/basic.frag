// 
//  basic.frag
//  rogue-descent
//  
//  Created by Jay Roberts on 2012-04-27.
//  Copyright 2012 GloryFish.org. All rights reserved.
// 

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
	return Texel(texture, texture_coords);
}