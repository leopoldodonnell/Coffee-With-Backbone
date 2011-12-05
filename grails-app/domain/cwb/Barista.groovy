package cwb

class Barista {
		Date dateCreated
		Date lastUpdated
		
		String name
		
    static constraints = {
			name blank: false, unique: true
    }
}
