package cwb

class CoffeeDrink {
	static expose = 'coffeeDrink'
	
	Date dateCreated
	Date lastUpdated
	
	String name
	
  static constraints = {
		name blank: false, unique: true
  }
}
