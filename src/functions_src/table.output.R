table.output <- function (data = data, scenario = scenario_name, export.doc = TRUE, 
          langue = "en", full.table = TRUE, title = NULL, decimal = 2, 
          results.folder = getwd()) 
{
  if (is.null(title)) {
    title = paste0("scenario:", scenario)
  }
  flextable::set_flextable_defaults(digits = decimal)
  time.horizon <- c(0, 1, 2, 3, 5, 10, endyear - startyear)
  years <- c(rep(startyear, length(time.horizon))) + time.horizon
  var_list.1 <- c("GDP", "CH", "I", "X", "M", "PVA", "PCH", 
                  "PY", "PX", "PM", "DISPINC_BT_VAL", "W", "RSAV_H_VAL")
  if (langue == "fr") {
    years_label <- c("Variable", "t", "t+1", "t+2", "t+3", 
                     "t+5", "t+10", "long terme")
    var_label.1 <- c("PIB (a)", "Consommation des ménages (a)", 
                     "Investissement (a)", "Exportations (a)", "Importations (a)", 
                     "Prix de VA (a)", "Prix à la consommation (a)", 
                     "Prix à la production (a)", "Prix des exportations (a)", 
                     "Prix des importations (a)", "Revenu des ménages en valeur (a)", 
                     "Salaire (a)", "Taux d'épargne des ménages (a)")
  }
  if (langue == "en") {
    years_label <- c("Variable", "t", "t+1", "t+2", "t+3", 
                     "t+5", "t+10", "long-term")
    var_label.1 <- c("GDP (a)", "Households consumption (a)", 
                     "Investment (a)", "Exports (a)", "Imports (a)", "Price of VA (a)", 
                     "Consumption price (a)", "Production price (a)", 
                     "Export price (a)", "Import price (a)", "Households disposable income (a)", 
                     "Nominal wages (a)", "Households saving rate (a)")
  }
  data_table.1 <- data %>% dplyr::filter(year %in% years, variable %in% 
                                           var_list.1) %>% dplyr::mutate(variation = round(100 * 
                                                                                             (get(scenario)/baseline - 1), decimal), variable = str_replace_all(variable, 
                                                                                                                                                                purrr::set_names(var_label.1, paste0("^", var_list.1, 
                                                                                                                                                                                                     "$")))) %>% dplyr::select(variable, year, variation) %>% 
    tidyr::pivot_wider(names_from = year, values_from = variation) %>% 
    dplyr::arrange(match(variable, var_label.1)) %>% `colnames<-`(years_label)
  if (full.table == TRUE) {
    var_list.2 <- c("F_L")
    if (langue == "fr") {
      var_label.2 <- c("Emploi en milliers (b)")
    }
    if (langue == "en") {
      var_label.2 <- c("Employment in thousand (b)")
    }
    data_table.2 <- data %>% dplyr::filter(year %in% years, 
                                           variable %in% var_list.2) %>% dplyr::mutate(variation = round((get(scenario) - 
                                                                                                            baseline), decimal), variable = stringr::str_replace_all(variable, 
                                                                                                                                                                     purrr::set_names(var_label.2, paste0("^", var_list.2, 
                                                                                                                                                                                                          "$")))) %>% dplyr::select(variable, year, variation) %>% 
      tidyr::pivot_wider(names_from = year, values_from = variation) %>% 
      dplyr::arrange(match(variable, var_label.2)) %>% 
      `colnames<-`(years_label)
    var_list.3 <- c("RBAL_TRADE_VAL", "RBAL_G_TOT_VAL", "RSAV_H_VAL", 
                    "MARKUP", "UNR")
    if (langue == "fr") {
      var_label.3 <- c("Balance commerciale (c)", "Solde Public (c)", 
                       "Taux d'épargne des ménages (d)", "Taux de marge des entreprises (d)", 
                       "Taux de chômage (d)")
    }
    if (langue == "en") {
      var_label.3 <- c("Trade balance (c)", "Government balance (c)", 
                       "Households saving rate (d)", "Mark-up rate (d)", 
                       "Unemployment rate (d)")
    }
    data_table.3 <- data %>% filter(year %in% years, variable %in% 
                                      var_list.3) %>% dplyr::mutate(variation = 100 * round(get(scenario), 
                                                                                            2 + decimal), variable = stringr::str_replace_all(variable, 
                                                                                                                                              purrr::set_names(var_label.3, paste0("^", var_list.3, 
                                                                                                                                                                                   "$")))) %>% dplyr::select(variable, year, variation) %>% 
      tidyr::pivot_wider(names_from = year, values_from = variation) %>% 
      dplyr::arrange(match(variable, var_label.3)) %>% 
      `colnames<-`(years_label)
    data_table <- dplyr::bind_rows(data_table.1, data_table.2, 
                                   data_table.3)
    if (langue == "fr") {
      footnote.tab <- c("(a): En déviation relative par rapport au baseline", 
                        "(b): En déviation absolue par rapport au baseline", 
                        "(c): en points de pourcentage du PIB", "(d): en pourcentage")
    }
    if (langue == "en") {
      footnote.tab <- c("(a): In relative deviation wrt baseline", 
                        "(b): In absolute deviation wrt baseline", "(c): In percentage points of GDP", 
                        "(d): In percentage")
    }
    j.tab <- (1:4)
  }
  else {
    data_table <- data_table.1
    if (langue == "fr") {
      footnote.tab <- c("(a): En deviation relative par rapport au baseline")
    }
    if (langue == "en") {
      footnote.tab <- c("(a): In relative deviation wrt baseline")
    }
    j.tab <- 1
  }
  output <- flextable::flextable(data_table) %>% width(width = 2.75, 
                                                       j = 1)
  output <- flextable::footnote(output, i = 1, j = j.tab, value = as_paragraph(footnote.tab), 
                                part = "header", ref_symbols = "", inline = TRUE)
  output <- flextable::set_caption(output, caption = title, 
                                   style = "Table Caption")
  if (export.doc == TRUE) {
    sect_properties <- officer::prop_section(page_size = page_size(orient = "landscape", 
                                                                   width = 12.3, height = 11.7), type = "continuous", 
                                             page_margins = page_mar())
    flextable::save_as_docx(output, path = file.path(results.folder, 
                                                     paste0(scenario, ".docx")), pr_section = sect_properties)
    utils::write.table(data_table, file.path(results.folder, 
                                             paste0(scenario, ".csv")))
  }
  output
}