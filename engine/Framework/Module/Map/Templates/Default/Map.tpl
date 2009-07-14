<p class="mapContainer"><img id="mapImg" src="{$mapPath}" /></p>
<script type="text/javascript">var map_cache = "{$mapPathCache}";</script>
<ol class="locations">
	{foreach from=$allLocations item=location}
		<li>{$location.name}</li>
	{/foreach}
</ol>