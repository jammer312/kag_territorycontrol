#include "gui_classes.as"

#define CLIENT_ONLY

const f32 gui_z=0;

void onTick(CBlob@ this) {
	CControls@ c=getControls();
	if(c is null) return;
	if(!this.isMyPlayer()) return;
	if(c.isKeyJustPressed(c.getActionKeyKey(AK_EAT))) {
		if(this.exists("gui_master")) {
			gui_master@ panel;
			this.get("gui_master",@panel);
			print("repositioning gui");
			panel.reposition(this.getInterpolatedPosition());
		} else {
			print("spawning gui");
			gui_master panel(this,this.getInterpolatedPosition(),Vec2f(40,40),gui_z);
			print("position: "+panel.position.x+" "+panel.position.y);
			this.set("gui_master",@panel);
			print("spawning renderer");
			Render::addBlobScript(Render::layer_postworld,this,"gui_control.as","render_master_gui");
		}
	}
	if(c.isKeyJustPressed(KEY_LBUTTON)||c.isKeyJustPressed(KEY_RBUTTON)) {
		print("mouse click event");
		Vec2f pos = c.getMouseWorldPos();
		if(this.exists("gui_master")) {
			print("now here");
			gui_master@ p;
			print("now there");
			this.get("gui_master",@p);
			print("and there");
			p.click_event(pos,c.isKeyJustPressed(KEY_LBUTTON));
			print("never happens");
		}
	}
}

void render_master_gui(CBlob@ this, int id) {
	if(this.hasTag("dead")) {
		this.clear("gui_master");
	}
	if(!this.exists("gui_master")) {	
		Render::RemoveScript(id);
		print("renderer ded");
		return;
	}
	gui_master@ panel;
	this.get("gui_master",@panel);
	panel.render();
}