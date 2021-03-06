#' Gets top content for a gauge, paginated.
#'
#' @export
#' @import httr data.table
#' @importFrom jsonlite fromJSON
#' @importFrom plyr compact rbind.fill
#' @importFrom lubridate today
#'
#' @template all
#' @param id Your gaug.es id
#' @param fromdate Date to get data from. Defaults to today.
#' @param todate Date to get data to. Defaults to today.
#' @param page page to return
#' @param keyname Your API key name in your .Rprofile file
#' @examples \dontrun{
#' gs_pageviews(id='4efd83a6f5a1f5158a000004', fromdate="2013-11-01", todate="2013-11-06")
#' }

gs_pageviews <- function(id, fromdate = NULL, todate = NULL, page=NULL,
                         keyname='GaugesKey')
{
  # assign today's date if no date specified
  if(is.null(fromdate))
    fromdate <- today()
  if(is.null(todate))
    todate <- today()

  # coerce to dates
  fromdate <- as.Date(fromdate)
  todate <- as.Date(todate)
  datestoget <- as.character(seq.Date(fromdate, todate, by="day"))

  getcontents <- function(x){
    temp <- gs_content(id=id, date=x, page=page, keyname=keyname)$data
    if(is.null(temp)){
      data.frame(date=x, title = "none", views = NA, stringsAsFactors = FALSE)
    } else {
      data.frame(date=x, temp[,c('title','views')], stringsAsFactors = FALSE)
    }
  }

  out <- lapply(datestoget, getcontents)
  out <- do.call(rbind.fill, out)
  dt <- data.table(out)
  data.frame(dt[, sum(views), by=title], stringsAsFactors = FALSE)
}
