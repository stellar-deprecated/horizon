+++
date = "2015-05-04T15:48:17-07:00"
draft = true
title = "Response Format"
+++

Rather than using a fully custom way of representing the resources we expose in Horizon, we use [HAL](http://stateless.co/hal_specification.html). HAL is a hypermedia format in JSON that remains simple while giving us a couple of benefits such as simpler client integration for several languages. See [this wiki page](https://github.com/mikekelly/hal_specification/wiki/Libraries) for a list of libraries.