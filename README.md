<!-- badges: start -->
<!-- badges: end -->

# surf

Basic 
[CSRF](https://en.wikipedia.org/wiki/Cross-site_request_forgery)
protection middleware for
[Ambiorix](https://ambiorix.dev)

When a `request` comes in (it ignores `GET`, `HEAD`, and `OPTIONS`)
it checks for the presence of a token.
It looks for said token in the following places, in that order:

- `_csrf` in the body of the response 
(e.g.: what was `POST`ed, see form example below),
both JSON and multipart.
- The `query` for `_csrf` value (`?_csrf=token`)
- Header `csrf-token`
- Header `xsrf-token`
- Header `x-csrf-token`
- Header `x-xsrf-token`

Where you need this token it can be retrieved with
`req$csrf_token`.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("surf")
```

## Example

__Valid__

``` r
library(surf)
library(ambiorix)

app <- Ambiorix$new()

# use the middleware
app$use(surf())

app$get("/", \(req, res){
  res$sendf(
    "<h1>What's your name?</h1>
    <form action='/' method='POST' enctype='multipart/form-data'>
      <input type='hidden' name='_csrf' value='%s' />
      <input type='text' name='name' />
      <input type='submit' value='send'/>
    </form>",
    req$csrf_token() # get token
  )
})

app$post("/", \(req, res) {
  body <- req$parse_multipart()
  res$sendf("Hi %s", body$name)
})

app$start()
```

__Invalid__

``` r
library(surf)
library(ambiorix)

app <- Ambiorix$new()

# use the middleware
app$use(surf())

app$get("/", \(req, res){
  # missing CSRF token
  res$send(
    "<h1>What's your name?</h1>
    <form action='/' method='POST' enctype='multipart/form-data'>
      <input type='text' name='name' />
      <input type='submit' value='send'/>
    </form>"
  )
})

app$post("/", \(req, res) {
  body <- req$parse_multipart()
  res$sendf("Hi %s", body$name)
})

app$start()
```


