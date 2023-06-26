flextable_theme <- function(x){
  x <- border_remove(x)
  std_border_h <- fp_border_default(width= 0.4,color = border_inner_header)
  std_border_b <- fp_border_default(width= 0.4,color = border_inner_body)
  std_border_o <- fp_border_default(width= 1,color = border_outer_all)
  x <- fontsize(x, size = 12, part = "all") %>% 
    font(fontname = "Arial", part = "all") %>% 
    align(j=c(2:col_numb),align="center") %>% 
    align(j=c(2:col_numb),align="center",part="header") %>%
    valign(j=c(1:col_numb),valign = "center", part = "all") %>%
    bg(bg = table_body, part = "body") %>% 
    bg(bg = table_header, part = "header") %>% 
    bg(bg = table_footer, part = "footer") %>% 
    color(color = table_header_text, part = "header") %>%
    color(color = table_footer_text, part = "footer") %>%
    color(color = table_body_text, part = "body") %>%
    #padding(padding = 6, part = "all") %>% 
    border_inner(border = std_border_h, part="header") %>%
    border_inner(border = std_border_b, part="body") %>%
    border_outer(part="all", border = std_border_o) %>%
    fix_border_issues() %>% 
    line_spacing(space = 0.3, part = "all") %>% 
    set_table_properties(layout = "autofit")
  x
}