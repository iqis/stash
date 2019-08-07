#' Stash an R Object onto Disk
#'
#' @param object an R object; name
#' @param dir_path path to a directory;character string
#' @param file_name name of the stash file
#'
#' @return a stash_ref obj
#' @export
#'
stash <- function(object,
                  dir_path = tempdir(),
                  file_name = paste0(sample(c(letters, LETTERS, 0:9), 20, TRUE), collapse = "")){
  res <-
    mod::thing({

      # Metadata
      file_path <- file.path(dir_path, paste0(file_name, ".Rstash"))
      obj_size <- utils::object.size(object)
      obj_class <-  class(object)

      # Dump Stash
      saveRDS(object, file_path)

      # Data
      ..content <- NULL

      # = Methods =

      load_content <- function() ..content <<- readRDS(file_path)
      remove_content <- function() ..content <<- NULL
      has_content <- function() !is.null(..content)

      has_stash_file <- function() file.exists(file_path)
      remove_stash <- function() if (has_stash_file()) file.remove(file_path)

    },
    dot = function(){
      if (has_content()) {
        return(..content)
      } else if (has_stash_file()) {
        return(readRDS(file_path))
      } else {
        stop(paste("stash file missing at:\n", file_path))
      }
    })

  class(res) <- c("stash_ref", class(res))
  res
}


#' Print Brief Info on a stash_ref
#'
#' @param x object
#' @param ... dot-dot-dot
#'
#' @return NULL
#' @export
#'
print.stash_ref <- function(x, ...){
  cat(paste0("<stash_ref>", " `", x$obj_class[1],"` ", x$obj_size, "\n"))
  cat("- ", paste(x$file_path))
}

#' Test if an Object is a stash_ref
#'
#' @param x object
#'
#' @return Logical
#' @export
#'
is_stash_ref <- function(x){
  inherits(x, "stash_ref")
}
