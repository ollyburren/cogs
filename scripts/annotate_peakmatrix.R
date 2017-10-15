library(devtools)
library(optparse)

install_github('ollyburren/cogs')

option_list = list(
        make_option(c("-p", "--pm"), type="character", default=NULL,
              help="Input peakMatrix file", metavar="character"),
        make_option(c("-b", "--ban"), type="character", default=NULL,
              help="Input bait design file", metavar="character"),
        make_option(c("-o", "--out"), type="character", default=NULL,
              help="Output file", metavar="character"),
        )

opt_parser = OptionParser(option_list=option_list);
args = parse_args(opt_parser)

if(is.null(args$pm) | is.null(args$ban) | is.null(args$out){
	print_help(opt_parser)
        stop("Arguments are missing")
}

annotate_pm(args$ban,args$pm,$args$out)
