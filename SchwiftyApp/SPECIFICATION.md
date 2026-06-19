
# Zadanie rekrutacyjne „Rick and Morty”

Twoim zadaniem jest przygotowanie prostej aplikacji, która pobierze dane z publicznie dostępnego
REST API (https://rickandmortyapi.com/documentation#rest) oraz zaprezentuje je użytkownikowi.
Warstwa graficzna aplikacji powinna być wykonana w całości przy użyciu SwiftUI. W ramach zadania
wymagane jest utworzenie client’a z wykorzystaniem Swift Concurrency, który dostarczy interfejs do
obsługi API. Dodatkowo aplikacja powinna być wykonana przy użyciu architektury MVVM lub TCA
(mile widziane). Wygląd oraz stylowanie aplikacji jest dowolne, jednakże aplikacja powinna być
estetyczna i stosować dobre praktyki dotyczące UX aplikacji mobilnych tzn. obsługa stanów takich jak
wczytywanie danych, brak danych, błąd z REST API, etc.

Aplikacja powinna składać się z minimum 3 widoków:

* `CharactersListView`
* `CharacterDetailsView`
* `EpisodeDetailsView`


`CharactersListView` odpowiada za wczytywanie i wyświetlanie listy bohaterów serialu „Rick and
Morty”. Powinien być on pierwszym ekranem, który zobaczy użytkownik oraz przy jego pierwszym
pojawieniu się powinien on wczytać dane i wyświetlić je użytkownikowi w formacie listy. Niezależnie
od ilości załadowanych danych, musi on pozwalać na odświeżenie listy (np. pull to refresh), które
powinno zresetować aktualnie załadowane dane i ponownie pobrać pierwszą stronę wyników, oraz
umożliwiać opcję wyszukiwania, przynajmniej po nazwie bohatera. Aplikacja powinna obsługiwać
paginację — kolejne strony danych powinny być ładowane automatycznie podczas przewijania listy
(infinite scroll).

Po przejściu z dowolnego elementu listy `CharactersListView`, powinniśmy zostać przekierowani
do `CharacterDetailsView`. Na tym ekranie powinny zostać zaprezentowane następujące
informacje:

* `name`
* `status`
* `gender`
* `origin`
* `location`
* `image`

Pod wyżej wymienionymi informacjami, powinna znajdować się lista odcinków, w których wystąpił
dany bohater. Odcinki powinny być zaprezentowane w formie tekstu "Odcinek <numer odcinka>". Po
naciśnięciu odcinka jesteśmy przekierowani do ekranu `EpisodeDetailsView` wyświetlającego takie
pola jak:

* `name`
* `air_date`
* `episode`
* `characters`

### Wymagania:

* Skonfigurowanie Xcode'a tak aby:
  * Korzystał z języka Swift w wersji 6 (Swift language version)
  * Używał nonisolated jako domyślnej izolacji (Default Actor Isolation)
  * Wspierał iOS’a od wersji 18.0 (Minimum Deployment Target)
* Zaprojektowanie:
  * API client’a wykorzystującego Swift Concurrency
  * Interfejs graficzny spełniający co najmniej ww. założenia z użyciem SwiftUI
* Stosowanie tzw. „dobrych praktyk” jak SOLID, KISS, DRY czy Clean Architecture
* Zastosowanie architektury MVVM

### Mile widziane:

* Użycie SPM (Swift Package Manager) do zarządzania zależnościami
* Dependency Injection poprzez użycie:
  * Dependencies (swift-dependencies)
  * Factory
  * lub innego dowolnego framework'a
* Wybór TCA (The Composable Architecture) zamiast MVVM jako docelowej architektury
  aplikacji (na co dzień pracujemy właśnie w TCA)

### Dodatkowym atutem będzie:

* Możliwość dodania bohatera do ulubionych (tak aby przy kolejnym wczytaniu danych został
on wyróżniony na tle pozostałych, np. był przypięty na górze listy)
* Wykorzystanie natywnych komponentów SwiftUI (np. `Button`, `GroupBox`, `Label`)
* Estetyka, stylowanie komponentów
* Obsługa błędów
* Testy jednostkowe (swift-testing)
* Testy snapshot’owe (swift-snapshot-testing)
