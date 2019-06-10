## [0.9.7] - 10 Jun 2019.

Consistent UI. Made installation guidelines more clearer.

## [0.9.6] - 9 Jun 2019.

Fixed fatal typo

## [0.9.5] - 9 Jun 2019.

Fixed issue where autocomplete overlay still remain after widget has been
disposed until whole app is restarted.

## [0.9.4] - 8 Jun 2019.

Working on library health.

## [0.9.3] - 8 Jun 2019.

Fixed issue with delayed call to searchPlace
 
`searchPlace` was being called (sometimes) after the widget has unmounted.  
This could have been due to some delay caused by the debouncer proceeding after
the widget has unmounted

## [0.9.2] - 8 Jun 2019.

Fixed issue where `setState` from http response callbacks was being called
after widget was disposed/unmounted

## [0.9.1] - 1 Jun 2019.

Updated guidelines to include missing configurations

## [0.9.0] - 1 Jun 2019.

Prepared for usage.

## [0.0.2] - 1 Jun 2019.

Fixes to package publication health. Added example.

## [0.0.1] - 1 Jun 2019.

Initial release.
