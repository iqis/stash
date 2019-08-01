#' Stash an R Object onto Disk
#'
#' @param object an R object; name
#' @param dir_path path to a directory;character string
#' @param file_name name of the stash file
#'
#' @return a stash_pointer obj
#' @export
#'
stash <- function(object,
                  dir_path = tempdir(),
                  file_name = paste0(sample(c(letters, LETTERS, 0:9), 20, TRUE), collapse = "")){
  res <-
    modular::thing({

      # Metadata
      file_path <- file.path(dir_path, paste0(file_name, ".Rstash"))
      obj_size <- object.size(object)
      obj_class <-  class(object)

      # Dump Stash
      saveRDS(object, file_path)

      # Data
      content <- NULL

      # = Methods =

      load_content <- function() content <<- readRDS(file_path)
      remove_content <- function() content <<- NULL
      has_content <- function() !is.null(content)

      stash_file_exists <- function() file.exists(file_path)
      remove_stash <- function() if (stash_file_exists()) file.remove(file_path)

      # `.` Read Data
      makeActiveBinding(".", function(){
        if (has_content()) {
          return(content)
        } else if (stash_file_exists()) {
          return(readRDS(file_path))
        } else {
          stop(paste("stash file missing at:\n", file_path))
        }
        }, env = environment())
    },force_public = TRUE, lock = FALSE)

  class(res) <- c("stash_pointer", class(res))
  res
}

#' Print Brief Info on a stash_pointer
#'
#' @param x
#'
#' @return NULL
#' @export
#'
print.stash_pointer <- function(x){
  cat(paste0("<stash_pointer>", " `", x$obj_class[1],"` ", x$obj_size, "\n"))
  cat("- ", paste(x$file_path))
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
