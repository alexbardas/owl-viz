<li>
	<a href="#">{{name}}
	  {{#isExpandable}}
		<i class="icon-chevron-{{#isExpanded}}down{{/isExpanded}}{{^isExpanded}}right{{/isExpanded}}"></i>
		<span class="badge badge-info">{{childrenNo}}</span>
	  {{/isExpandable}}
	</a>
</li>