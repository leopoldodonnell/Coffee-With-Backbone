/*
 * BaristaController.groovy
 * cwb
 * 
 * Created by Leopold ODonnell on 05/12/2011.
 * 
 * Copyright (c) 2011 BigLife Labs, Inc.
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package cwb

import grails.converters.JSON
import grails.converters.JSON.*

class BaristaController {
	static scaffold = Barista
	
	def list() {
		withFormat {
			html {
				[baristaInstanceList: Barista.list(params), baristaInstanceTotal: Barista.count()]				
			}
			json {
				render Barista.list(params) as JSON
			}
		}
	}
	
	def show() {
		Barista barista = Barista.get(params.id)
		withFormat {
			html {
				if (!barista) {
					redirect(action: "list")
				}
				[baristaInstance: barista]
			}
			json {
				if (!barista) {
					// Not Found
					render "${params.id} not found.", status: 404
				}
				render barista as JSON
			}
		}
	}
	
	def edit() {
		return show()
	}
		
	def save() {
		Barista barista
		
		if (request.format == 'json') {
			barista = new Barista(request.JSON)
			if (!barista?.validate()) {
 				// Bad syntax from params
				render "Could not validate parameters to save Barista", status: 400
			}
			else if (!barista?.save(flush:true)) {
 				// Something went wrong to prevent the save
				render "Could not save the Barista - Internal Error", status: 500
			}
			else {
				render text: barista as JSON, contentType: 'application/json', status: 201
			}
			return
		} 
		
		// HTML
		barista = new Barista(params)
		if (barista?.save()) {
			flash.message = "Successfully added a new Barista"
		}
		else {
			flash.error = "Could not save the new Barista"
		}
		chain(action: '')
	}
	
	def update() {
		Barista barista = Barista.get(params.id)
		
		if (request.format == 'json') {
			if (!barista) {
				// Not Found
				render "${parsedParams.id} not found.", status: 404
			}
			
			barista.properties = request.JSON 
			if (!barista.validate()) {
					// Bad syntax from params
					render "Could not validate parameters to save Barista", status: 400
			}
			else if (!barista.save()) {
				// Something went wrong to prevent the save
				render "Could not save the Barista - Internal Error", status: 500
			}
			else {
				render text: barista as JSON, contentType: 'application/json', status: 200
			}
			return			
		}
		
		// Handle HTML
		if (!barista) {
			flash.error = "There was a problem updating the Barista"
			redirect(action: 'list')
		}
		barista.properties = params
		if (barista.save()) {
			flash.message = "Successfully updated the Barista"
		}
		else {
			flash.error = "There was a problem updating the Barista"
		}
		chain(action: '')
	}
	
	
	def delete() {
		Barista barista = Barista.get(params?.id)

		// The only way, it seems, to know if the delete is an Ajax Delete
		boolean isJson = request.getHeader('accept')  =~ /application\/json/
		
		if (isJson) {
			if (!barista) {
				response.status = 404 // Not Found
				render 'Could not delete the Barista. Possibly not found.'
			} else {
				barista.delete()	// TODO: try catch a flush:true call to delete
				render '{}'				// Send back a valid JSON response
			}			
			return
		}
		// HTML
		if (!barista) {
			flash.error = "There was a problem deleting the Barista"
		} else {
			barista.delete() // TODO: try catch a flush:true call to delete
			flash.message = "The Barista was successfully deleted"
		}
		chain(action: '')			
	}
}
