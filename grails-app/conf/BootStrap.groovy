
import cwb.Barista

class BootStrap { 

    def init = { servletContext ->
			def baristas = [
				[name: 'Cuppajaweha'],
				[name: 'Per Oevur'],
				[name: 'Spike'],
				[name: 'Marc Iato']				
			]
			baristas.each { (new Barista(it)).save() }
    }
    def destroy = {
    }
}
