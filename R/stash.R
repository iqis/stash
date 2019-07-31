#' Stash an R Object onto Disk
#'
#' @param object an R object; name
#' @param dir_path path to a directory;character string
#'
#' @return a stash_pointer obj
#' @export
#'
stash <- function(object,
                  dir_path = tempdir(),
                  file_name = paste0(sample(c(letters, LETTERS, 0:9), 20, TRUE), collapse = "")){
  file_name <- paste0(file_name, ".Rstash")
  file_path <- file.path(dir_path, file_name)
  saveRDS(object, file_path)
  f <- function(){
    if (!file.exists(file_path)){
      stop("stash file missing.")
    } else {
      readRDS(file_path)
    }
  }

  structure(f,
            class = c("stash_pointer", class(f)),
            file_path = file_path,
            obj_size = format(object.size(object), unit = "MB", digits = 2),
            obj_class = class(object)
  )
}

#' Print Brief Info on a stash_pointer
#'
#' @param x
#'
#' @return NULL
#' @export
#'
print.stash_pointer <- function(x){
  cat(paste0("<stash_pointer>", " `", attr(x, "obj_class")[1],"` ", attr(x, "obj_size"), "\n"))
  cat("- ", paste(attr(x, "file_path")))
}

#' Delete Cache on Disk
#'
#' @param stash_pointer
#'
#' @return NULL
#' @export
#'
clear_stash <- function(stash_pointer){
  file_path <- attr(stash_pointer, "file_path")
  if (file.exists(file_path)){
    file.remove(file_path)
  }
}

stash_exists <- function(stash_pointer){
  file.exists(attr(stash_pointer, "file_path"))
}

#' Test if an Object is a stash_pointer
#'
#' @param x
#'
#' @return Logical
#' @export
#'
is_stash_pointer <- function(x){
  inherits(x, "stash_pointer")
}
