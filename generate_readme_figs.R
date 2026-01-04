#!/usr/bin/env Rscript
# Generate README figures for maschooldata

library(ggplot2)
library(dplyr)
library(scales)
devtools::load_all(".")

# Create figures directory
dir.create("man/figures", recursive = TRUE, showWarnings = FALSE)

# Theme
theme_readme <- function() {
  theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
}

colors <- c("total" = "#2C3E50", "white" = "#3498DB", "black" = "#E74C3C",
            "hispanic" = "#F39C12", "asian" = "#9B59B6")

# Fetch data
message("Fetching data...")
enr <- fetch_enr_multi(2016:2024)
enr_current <- fetch_enr(2024)

# 1. Boston decline
message("Creating Boston decline chart...")
boston <- enr %>%
  filter(is_district, district_id == "0035",
         subgroup == "total_enrollment", grade_level == "TOTAL")

p <- ggplot(boston, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "Boston Public Schools Enrollment",
       subtitle = "Steady decline over the past decade",
       x = "School Year", y = "Students") +
  theme_readme()
ggsave("man/figures/boston-decline.png", p, width = 10, height = 6, dpi = 150)

# 2. Gateway cities
message("Creating Gateway cities chart...")
gateway <- enr %>%
  filter(is_district, district_id %in% c("0281", "0365", "0145"),
         subgroup == "total_enrollment", grade_level == "TOTAL")

p <- ggplot(gateway, aes(x = end_year, y = n_students, color = district_name)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = comma) +
  labs(title = "Gateway Cities Enrollment",
       subtitle = "Springfield, Worcester, and Lowell",
       x = "School Year", y = "Students", color = "") +
  theme_readme()
ggsave("man/figures/gateway-cities.png", p, width = 10, height = 6, dpi = 150)

# 3. Demographics shift
message("Creating demographics chart...")
demo <- enr %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian"))

p <- ggplot(demo, aes(x = end_year, y = pct * 100, color = subgroup)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_color_manual(values = colors) +
  labs(title = "Massachusetts Demographics Shift",
       subtitle = "Percent of student population by race/ethnicity",
       x = "School Year", y = "Percent", color = "") +
  theme_readme()
ggsave("man/figures/demographics-shift.png", p, width = 10, height = 6, dpi = 150)

# 4. Cape decline
message("Creating Cape decline chart...")
cape <- enr %>%
  filter(is_district, grepl("Barnstable|Nauset|Monomoy|Martha|Nantucket", district_name),
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(n_students = sum(n_students, na.rm = TRUE))

p <- ggplot(cape, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma) +
  labs(title = "Cape and Islands Enrollment",
       subtitle = "Combined enrollment for Cape Cod and Island districts",
       x = "School Year", y = "Students") +
  theme_readme()
ggsave("man/figures/cape-decline.png", p, width = 10, height = 6, dpi = 150)

# 5. COVID kindergarten
message("Creating kindergarten chart...")
k_trend <- enr %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "06", "12")) %>%
  mutate(grade_label = case_when(
    grade_level == "K" ~ "Kindergarten",
    grade_level == "01" ~ "Grade 1",
    grade_level == "06" ~ "Grade 6",
    grade_level == "12" ~ "Grade 12"
  ))

p <- ggplot(k_trend, aes(x = end_year, y = n_students, color = grade_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2021, linetype = "dashed", color = "red", alpha = 0.5) +
  scale_y_continuous(labels = comma) +
  labs(title = "COVID Impact on Grade-Level Enrollment",
       subtitle = "Kindergarten hit hardest in 2020-21",
       x = "School Year", y = "Students", color = "") +
  theme_readme()
ggsave("man/figures/covid-kindergarten.png", p, width = 10, height = 6, dpi = 150)

# 6. Charter enrollment
message("Creating charter chart...")
charter <- enr %>%
  filter(is_charter, is_campus, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(n_students = sum(n_students, na.rm = TRUE), n_schools = n())

p <- ggplot(charter, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma) +
  labs(title = "Massachusetts Charter School Enrollment",
       subtitle = "Total students across all charter schools",
       x = "School Year", y = "Students") +
  theme_readme()
ggsave("man/figures/charter-enrollment.png", p, width = 10, height = 6, dpi = 150)

# 7. Economic disadvantage
message("Creating econ disadvantage chart...")
econ <- enr %>%
  filter(is_state, subgroup == "econ_disadv", grade_level == "TOTAL")

p <- ggplot(econ, aes(x = end_year, y = pct * 100)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  labs(title = "Economically Disadvantaged Students",
       subtitle = "Percent of MA students classified as economically disadvantaged",
       x = "School Year", y = "Percent") +
  theme_readme()
ggsave("man/figures/econ-disadvantage.png", p, width = 10, height = 6, dpi = 150)

# 8. EL concentration
message("Creating EL chart...")
el <- enr_current %>%
  filter(is_district, subgroup == "lep", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  head(10) %>%
  mutate(district_label = reorder(district_name, n_students))

p <- ggplot(el, aes(x = district_label, y = n_students)) +
  geom_col(fill = colors["total"]) +
  coord_flip() +
  scale_y_continuous(labels = comma) +
  labs(title = "English Learners by District",
       subtitle = "Top 10 districts by number of EL students",
       x = "", y = "English Learner Students") +
  theme_readme()
ggsave("man/figures/el-concentration.png", p, width = 10, height = 6, dpi = 150)

# 9. Suburban stability
message("Creating suburban chart...")
suburbs <- enr %>%
  filter(is_district, district_id %in% c("0195", "0139", "0325"),
         subgroup == "total_enrollment", grade_level == "TOTAL")

p <- ggplot(suburbs, aes(x = end_year, y = n_students, color = district_name)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = comma) +
  labs(title = "Suburban Ring Enrollment",
       subtitle = "Newton, Lexington, and Wellesley",
       x = "School Year", y = "Students", color = "") +
  theme_readme()
ggsave("man/figures/suburban-stable.png", p, width = 10, height = 6, dpi = 150)

# 10. Regional districts
message("Creating regional districts chart...")
regional <- enr_current %>%
  filter(is_district, grepl("Regional", district_name),
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  head(10) %>%
  mutate(district_label = reorder(district_name, n_students))

p <- ggplot(regional, aes(x = district_label, y = n_students)) +
  geom_col(fill = colors["total"]) +
  coord_flip() +
  scale_y_continuous(labels = comma) +
  labs(title = "Regional School Districts",
       subtitle = "Top 10 regional districts by enrollment",
       x = "", y = "Students") +
  theme_readme()
ggsave("man/figures/regional-districts.png", p, width = 10, height = 6, dpi = 150)

message("Done! Generated 10 figures in man/figures/")
