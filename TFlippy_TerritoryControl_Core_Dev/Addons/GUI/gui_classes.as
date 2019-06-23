const string gui_panel_texture_name = "__gptn";

bool textures_ready=false;

void prepare_textures() {
	// if(!Texture::exists(gui_panel_texture_name)) {
	// 	if(!Texture::createBySize(gui_panel_texture_name, 8, 8)) {
	// 		warn("texture creation failed");
	// 	}
	// 	else {
	// 		ImageData@ edit = Texture::data(gui_panel_texture_name);

	// 		for(int i = 0; i < edit.size(); i++) {
	// 			edit[i] = SColor(0x55ff99ff);
	// 		}

	// 		if(!Texture::update(gui_panel_texture_name, edit)) {
	// 			warn("texture update failed");
	// 		}
	// 	}
	// }
	print("prepared textures");
	textures_ready=true;
}

bool is_between(Vec2f a, Vec2f b, Vec2f c) {
	return !(b.x<a.x||b.y<a.y||b.x>c.x||b.y>c.y);
}

class gui_panel {
	Vec2f position;
	Vec2f prev_offset;
	Vec2f dimensions;
	f32 z;
	bool render_ready;
	
	gui_panel@[] childs;

	gui_panel(Vec2f pos=Vec2f(0,0),Vec2f dims=Vec2f(0,0),f32 _z = 0) {
		position=pos;
		z=_z;
		dimensions=dims;
		render_ready=false;
	}

	Vec2f[] quad_xy;
	Vec2f[] quad_uv;

	void render(Vec2f offset=Vec2f(0,0)) {
		if(!render_ready||prev_offset!=offset) {
			prepare_render(offset);
			prev_offset=offset;
		}
		Render::SetTransformWorldspace();
		Render::Quads("gui_panel.png",z,quad_xy,quad_uv);
		for(int i=0;i<childs.size();++i) {
			childs[i].render(offset+position);
		}
	}

	void reposition(Vec2f new_position) {
		position=new_position;
		render_ready=false;
	}

	void prepare_render(Vec2f offset) {
		if(!textures_ready) {
			prepare_textures();
		}

		if(quad_uv.empty()) {		
			quad_uv.push_back(Vec2f(0,0));
			quad_uv.push_back(Vec2f(1,0));
			quad_uv.push_back(Vec2f(1,1));
			quad_uv.push_back(Vec2f(0,1));
		}

		quad_xy.clear();
		quad_xy.push_back(offset+position);
		quad_xy.push_back(offset+position+Vec2f(dimensions.x,0));
		quad_xy.push_back(offset+position+dimensions);
		quad_xy.push_back(offset+position+Vec2f(0,dimensions.y));

		print("prepared render");
		render_ready=true;
	}

	void click_event(Vec2f pos, bool left) {
		propagate_click_event(pos, left);
		print("base mouse click event");
		return;
	}

	void propagate_click_event(Vec2f pos,bool left) {
		for(int i=0;i<childs.size();++i) {
			gui_panel@ p=childs[i];
			if(is_between(p.position,pos,p.position+p.dimensions)) {
				p.click_event(pos-p.position,left);
				print("propagating");
			}
		}
	}
}

class gui_master: gui_panel {
	CBlob@ master;
	gui_master(CBlob@ mst,Vec2f pos=Vec2f(0,0),Vec2f dims=Vec2f(0,0),f32 _z = 0) {
		@master=@mst;
		super(pos,dims,_z);
	}

	void click_event(Vec2f pos, bool left) {
		pos-=position;
		if(!is_between(Vec2f(0,0),pos,dimensions)) {
			if(master is null) {
				print("wtf");
				return;
			}
			print("checking existance");
			if(!master.exists("gui_master")) {
				print("wtf^2");
				return;
			}
			print("checking null");
			gui_master@ p;
			master.get("gui_master",@p);
			if(p is null) {
				print("wtf_v2");
				return;
			}
			print("writing null over whatever");
			master.set("gui_master",@p);
			print("trying to delet gui");
			master.clear("gui_master"); //delet gui
			print("delet gui");
			return;
		}
		print("clicked inside master");
		gui_panel::click_event(pos,left);
	}
}