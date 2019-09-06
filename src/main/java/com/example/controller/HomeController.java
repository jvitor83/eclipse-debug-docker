package com.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/api")
public class HomeController {

	@GetMapping("/home")
    public String greeting() {
		String retorno = "Hello Docker no Eclipse 19!"; 
        return retorno;
    }
}
