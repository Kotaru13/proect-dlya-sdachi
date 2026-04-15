# Запускайте в PowerShell В ТОЙ ЖЕ УЧЁТНОЙ ЗАПИСИ, где выполнили: gh auth login
# Каталог: папка с проектом (рядом с app.py).
#
# Перед первым использованием Projects:
#   gh auth refresh -s project -h github.com

$ErrorActionPreference = "Stop"
$Owner = "Kotaru13"
$Repo = "proect-dlya-sdachi"
$Full = "$Owner/$Repo"

Write-Host "Проверка gh..."
gh auth status

Write-Host "Расширение прав для GitHub Projects (если уже есть — можно пропустить)..."
gh auth refresh -s project -h github.com

# --- PR (если ещё не создавали через веб) ---
$head = "chore/submission-final"
Write-Host "Проверка ветки $head..."
git fetch origin
$hasBranch = git show-ref --verify --quiet "refs/heads/$head"; if ($LASTEXITCODE -ne 0) {
  git checkout main
  git pull origin main
  git checkout -b $head
} else {
  git checkout $head
}

git pull origin main --no-edit 2>$null
git push -u origin $head

$existing = gh pr list -R $Full --head "$Owner`:$head" --json number --jq "length"
if ([int]$existing -eq 0) {
  gh pr create -R $Full --base main --head $head `
    --title "Финальное оформление сдачи практики" `
    --body "Добавлены ссылки для сдачи в README. Объединение в main для фиксации Pull Request по заданию."
  gh pr merge -R $Full --merge --delete-branch
} else {
  Write-Host "PR для $head уже есть — пропуск создания."
}

git checkout main
git pull origin main

# --- GitHub Project ---
Write-Host "Создание проекта..."
$created = gh project create --owner $Owner --title "Практика: менеджер задач (сдача)" --format json | ConvertFrom-Json
$projNum = $created.number
Write-Host "Проект №$projNum"

gh project link $projNum --owner $Owner -R $Full

Write-Host "Поля проекта..."
gh project field-create $projNum --owner $Owner --name "Priority" --data-type SINGLE_SELECT --single-select-options "High,Medium,Low"
gh project field-create $projNum --owner $Owner --name "Start Date" --data-type DATE
gh project field-create $projNum --owner $Owner --name "End Date" --data-type DATE
gh project field-create $projNum --owner $Owner --name "Original Estimate" --data-type NUMBER
# Если поле Status уже создано шаблоном и имя занято — переименуйте в UI или измените имя ниже.
gh project field-create $projNum --owner $Owner --name "Status" --data-type SINGLE_SELECT --single-select-options "Proposed,Active,Resolved,Completed"

function New-IssueToProject {
  param([string]$Title, [string]$Body)
  $url = gh issue create -R $Full -t $Title -b $Body -a $Owner
  gh project item-add $projNum --owner $Owner --url $url
  return $url
}

Write-Host "Задачи (issues) и добавление в проект..."
New-IssueToProject "Инициализация структуры проекта" "Создать файлы app.py, README.md, .gitignore; подготовить запуск в IDE."
New-IssueToProject "Хранение задач в JSON" "Реализовать загрузку и сохранение списка задач в tasks.json."
New-IssueToProject "CLI-меню операций" "Добавить пункты меню: список, добавление, выполнение, удаление, статистика."
New-IssueToProject "Валидация ввода" "Проверка пустого текста, длины, дубликатов; нормализация пробелов."
New-IssueToProject "Документация и тест-план" "Обновить README: запуск, ручная проверка, описание веток."
New-IssueToProject "Публикация и Pull Request" "Запушить ветки, оформить PR и слияние в main."

Write-Host ""
Write-Host "Готово. Откройте проект в браузере и:"
Write-Host "  1) Для каждой задачи заполните Priority, Start Date, End Date, Original Estimate, Status."
Write-Host "  2) Убедитесь, что есть представления: Table, Board, Roadmap (добавьте через + View, если нет)."
Write-Host "  3) Скопируйте URL проекта в README (раздел «Ссылки для сдачи») и сделайте коммит."
gh project view $projNum --owner $Owner --web
