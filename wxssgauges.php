<?php
############################################################################
# Steel Series Gauges page for the Saratoga template (WeeWX)
#
# Wraps ./ssg/gauges-ss-basic-inc.php (from the SteelSeries-Weather-Gauges
# web_server distribution) in the template header/menu/footer.
# ssg/scripts/gauges.js is configured by customizeSettings.sh to read
# WeeWX gauge-data.txt from ./mount/ (weewx-realtime_gauge-data extension).
############################################################################
require_once("Settings.php");
require_once("common.php");
############################################################################
$useHTML5 = true;  // force this page to use HTML5 instead of XHTML 1.0-Transitional
$useUTF8 = true;   // force this page to convert language files to UTF8 for display
#
$TITLE = langtransstr($SITE['organ']) . " - " .langtransstr('Current Weather Gauges');
$showGizmo = true;  // set to false to exclude the gizmo
include("top.php");
############################################################################
$ssgDir = './ssg/'; // relative directory location of the SteelSeries gauge directory
############################################################################
?>
  <link rel="stylesheet" href="<?php echo $ssgDir;?>css/gauges-ss.css">
</head>
<body>
<?php
############################################################################
include("header.php");
############################################################################
include("menubar.php");
?>

<div id="main-copy">

   <h2><?php langtrans('Current Weather Gauges'); ?></h2>
<?php
  if(file_exists($ssgDir.'gauges-ss-basic-inc.php')) {
    include($ssgDir.'gauges-ss-basic-inc.php');
  } else {
    print "<p>".$ssgDir."gauges-ss-basic-inc.php not found.</p>\n";
  }

  $ssLanguages = array(
	// available languages for the Steel Series Gauges by Mark Crossley
	// from the LANG.ll= entries in $ssgDir scripts/language.min.js file
	  'en' => 'EN', // english
	  'fr' => 'FR', // french
	  'de' => 'DE', // german
	  'nl' => 'NL', // dutch
	  'se' => 'SE', // swedish
	  'dk' => 'DK', // danish
	  'fi' => 'FI', // finnish (Suomi)
	  'no' => 'NO', // norwegian
	  'it' => 'IT', // italian
	  'es' => 'ES', // spanish
	  'ct' => 'CT', // catalan
	  'el' => 'GR', // greek
	);
  $toLang = isset($ssLanguages[$SITE['lang']]) ? $ssLanguages[$SITE['lang']] : 'EN';
  print "<script type=\"text/javascript\">
   changeLang(LANG.$toLang);  // change SteelSeries language\n</script>\n";
?>
</div><!-- end main-copy -->

<?php
############################################################################
include("footer.php");
############################################################################
# End of Page
############################################################################
?>
