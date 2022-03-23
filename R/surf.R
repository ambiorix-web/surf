KEY <- "_csrf"

#' CSRF
#' 
#' @importFrom ambiorix token_create
#' 
#' @export
surf <- \() {
  \(req, res) {

    secret <- get_secret(req$cookie[[KEY]])

    req$csrf_token <- \(){
      sec <- get_secret(req$cookie[[KEY]])

      if(length(sec) == 0L){
        sec <- token_create()
        res$cookie(
          KEY,
          sec
        )
      }

      if(isTRUE(!length(secret) == 0L && sec == secret))
        return(sec)

      secret <<- token_create()

      return(secret)
    }

    if(isTRUE(length(secret) == 0L)){
      secret <- token_create()
      res$cookie(
        KEY,
        secret
      )
      return()
    }

    if(req$REQUEST_METHOD %in% c("GET", "HEAD", "OPTIONS"))
      return()

    if(isTRUE(secret == get_param(req)))
      return()

    res$status <- 403L
    res$send("Invalid CSRF token")
  }
}

get_param <- \(req) {
  # check form
  body <- req$parse_multipart()
  if(!is.null(body[[KEY]]))
    return(body[[KEY]])

  body <- req$parse_json()
  if(!is.null(body[[KEY]]))
    return(body[[KEY]])

  # check id
  if(!is.null(req$query[[KEY]]))
    return(req$query[[KEY]])

  headers <- c(
    "csrf-token",
    "xsrf-token",
    "x-csrf-token",
    "x-xsrf-token"
  )

  for(valid in headers) {
    head <- req$headers[[valid]]
    if(!is.null(head))
      return(head)
  }

  cat("Missing", KEY, "token\n")  
  return(NULL)
}

get_secret <- \(cookie) {
  if(is.null(cookie))
    return()

  if(is.character(cookie) && cookie == "")
    return()

  return(cookie)
}
