function setup_charts() {
  console.log("setup_charts()");
  margins = [20, 20, 30, 20];
  width = 960 - margins[1] - margins[3];
  height = 500 - margins[0] - margins[2];

  duration = 0;
  delay = 0;

  color = d3.scale.category10();

  svg = d3.select("div.charts")
    .append("svg")
    .attr("class", "col-md-12")
    .attr("width", width + margins[1] + margins[3])
    .attr("height", height + margins[0] + margins[2])
    .append("g")
    .attr("transform", "translate(" + margins[3] + "," + margins[0] + ")");

  // A line generator, for the dark stroke.
  line = d3.svg.line()
    .interpolate("basis")
    .x(function(d) { return x(d.created_at); })
    .y(function(d) { return y(d.raw_data); });

  // A line generator, for the dark stroke.
  axis = d3.svg.line()
    .interpolate("basis")
    .x(function(d) { return x(d.created_at); })
    .y(height);

  // A area generator, for the dark stroke.
  area = d3.svg.area()
    .interpolate("basis")
    .x(function(d) { return x(d.created_at); })
    .y1(function(d) { return y(d.raw_data); });

  d3.json("welcome.json", function(data) {
    parse = d3.time.format("%b %Y").parse;

    // Nest data_point values by sensor_id.
    sensor_ids = d3.nest()
      .key(function(d) { return d.sensor_id; })
      .entries(data_points = data);

    // Parse created_at and numbers. We assume values are sorted by created_at.
    // Also compute the maximum raw_data per sensor_id, needed for the y-domain.
    sensor_ids.forEach(function(s) {
      s.values.forEach(function(d) { d.created_at = Date.parse(d.created_at); d.raw_data = +d.raw_data; });
      s.maxRawData = d3.max(s.values, function(d) { return d.raw_data; });
      s.sumRawData = d3.sum(s.values, function(d) { return d.raw_data; });
    });

    // Sort by maximum raw_data, descending.
    sensor_ids.sort(function(a, b) { return b.maxRawData - a.maxRawData; });

    g = svg.selectAll("g")
      .data(sensor_ids)
      .enter().append("g")
      .attr("class", "sensor_id");
  });

  $("#clear_charts-btn").on("click", clear_charts);
  $("#lines-btn").on("click", lines);
  $("#horizons-btn").on("click", horizons);
  $("#areas-btn").on("click", areas);
  $("#stackedArea-btn").on("click", stackedArea);
  $("#streamgraph-btn").on("click", streamgraph);
  $("#overlappingArea-btn").on("click", overlappingArea);
  $("#groupedBar-btn").on("click", groupedBar);
  $("#stackedBar-btn").on("click", stackedBar);

  function clear_charts() {
    console.log("clear_charts()");
    $("g.sensor_id").html("");
  }

  function lines() {
    console.log("lines()");
    clear_charts();
    x = d3.time.scale().range([0, width - 60]);
    y = d3.scale.linear().range([height / 4 - 20, 0]);

    // Compute the minimum and maximum created_at across sensor_ids.
    x.domain([
        d3.min(sensor_ids, function(d) { return new Date(d.values[0].created_at); }),
        d3.max(sensor_ids, function(d) { return new Date(d.values[d.values.length - 1].created_at); })
    ]);

    // Each channel is grouped using the <g> tag
    channels = svg.selectAll("g.sensor_id")
      .attr("transform", function(d, i) { return "translate(0," + (i * height / 4 + 10) + ")"; });

    channels.each(function(d) {
      var channel = d3.select(this);

      channel.append("path")
        .attr("class", "line");

      channel.append("circle")
        .attr("r", 5)
        .style("fill", function(d) { return color(d.key); })
        .style("stroke", "#000")
        .style("stroke-width", "2px");

      channel.append("text")
        .attr("class", "chart-label")
        .attr("x", 12)
        .attr("dy", ".31em")
        .text(d.key);
    });

    function draw(k) {
      g.each(function(d) {
        var e = d3.select(this);
        y.domain([0, d.maxRawData]);

        e.select("path")
          .attr("d", function(d) { return line(d.values.slice(0, k + 1)); });

        e.selectAll("circle, text")
          .data(function(d) { return [d.values[k], d.values[k]]; })
          .attr("transform", function(d) { return "translate(" + x(d.created_at) + "," + y(d.raw_data) + ")"; });
      });
    }

    var k = 1, n = sensor_ids[0].values.length;
    draw(n - 1);
  }

  function horizons() {
    lines();
    svg.insert("defs", ".sensor_id")
      .append("clipPath")
      .attr("id", "clip")
      .append("rect")
      .attr("width", width)
      .attr("height", height / 4 - 20);

    var color = d3.scale.ordinal()
      .range(["#c6dbef", "#9ecae1", "#6baed6"]);

    var g = svg.selectAll(".sensor_id")
      .attr("clip-path", "url(#clip)");

    area
      .y0(height / 4 - 20);

    g.select("circle").transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + (width - 60) + "," + (-height / 4) + ")"; })
      .remove();

    g.select("text").transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + (width - 60) + "," + (height / 4 - 20) + ")"; })
      .attr("dy", "0em");

    g.each(function(d) {
      y.domain([0, d.maxRawData]);

      d3.select(this).selectAll(".area")
        .data(d3.range(3))
        .enter().insert("path", ".line")
        .attr("class", "area")
        .attr("transform", function(d) { return "translate(0," + (d * (height / 4 - 20)) + ")"; })
        .attr("d", area(d.values))
        .style("fill", function(d, i) { return color(i); })
        .style("fill-opacity", 1e-6);

      y.domain([0, d.maxRawData / 3]);

      d3.select(this).selectAll(".line").transition()
        .duration(duration)
        .attr("d", line(d.values))
        .style("stroke-opacity", 1e-6);

      d3.select(this).selectAll(".area").transition()
        .duration(duration)
        .style("fill-opacity", 1)
        .attr("d", area(d.values))
        .each("end", function() { d3.select(this).style("fill-opacity", null); });
    });

    // setTimeout(areas, duration + delay);
  }

  function areas() {
    // horizons();
    var g = svg.selectAll(".sensor_id");

    axis.y(height / 4 - 21);

    g.select(".line")
      .attr("d", function(d) { return axis(d.values); });

    g.each(function(d) {
      y.domain([0, d.maxRawData]);

      d3.select(this).select(".line").transition()
        .duration(duration)
        .style("stroke-opacity", 1)
        .each("end", function() { d3.select(this).style("stroke-opacity", null); });

      d3.select(this).selectAll(".area")
        .filter(function(d, i) { return i; })
        .transition()
        .duration(duration)
        .style("fill-opacity", 1e-6)
        .attr("d", area(d.values))
        .remove();

      d3.select(this).selectAll(".area")
        .filter(function(d, i) { return !i; })
        .transition()
        .duration(duration)
        .style("fill", color(d.key))
        .attr("d", area(d.values));
    });

    svg.select("defs").transition()
      .duration(duration)
      .remove();

    g.transition()
      .duration(duration)
      .each("end", function() { d3.select(this).attr("clip-path", null); });

    // setTimeout(stackedArea, duration + delay);
  }

  function stackedArea() {
    // areas();
    var stack = d3.layout.stack()
      .values(function(d) { return d.values; })
      .x(function(d) { return d.created_at; })
      .y(function(d) { return d.raw_data; })
      .out(function(d, y0, y) { d.raw_data0 = y0; })
      .order("reverse");

    stack(sensor_ids);

    y
      .domain([0, d3.max(sensor_ids[0].values.map(function(d) { return d.raw_data + d.raw_data0; }))])
      .range([height, 0]);

    line
      .y(function(d) { return y(d.raw_data0); });

    area
      .y0(function(d) { return y(d.raw_data0); })
      .y1(function(d) { return y(d.raw_data0 + d.raw_data); });

    var t = svg.selectAll(".sensor_id").transition()
      .duration(duration)
      .attr("transform", "translate(0,0)")
      .each("end", function() { d3.select(this).attr("transform", null); });

    t.select("path.area")
      .attr("d", function(d) { return area(d.values); });

    t.select("path.line")
      .style("stroke-opacity", function(d, i) { return i < 3 ? 1e-6 : 1; })
      .attr("d", function(d) { return line(d.values); });

    t.select("text")
      .attr("transform", function(d) { d = d.values[d.values.length - 1]; return "translate(" + (width - 60) + "," + y(d.raw_data / 2 + d.raw_data0) + ")"; });

    // setTimeout(streamgraph, duration + delay);
  }

  function streamgraph() {
    // stackedArea();
    var stack = d3.layout.stack()
      .values(function(d) { return d.values; })
      .x(function(d) { return d.created_at; })
      .y(function(d) { return d.raw_data; })
      .out(function(d, y0, y) { d.raw_data0 = y0; })
      .order("reverse")
      .offset("wiggle");

    stack(sensor_ids);

    line
      .y(function(d) { return y(d.raw_data0); });

    var t = svg.selectAll(".sensor_id").transition()
      .duration(duration);

    t.select("path.area")
      .attr("d", function(d) { return area(d.values); });

    t.select("path.line")
      .style("stroke-opacity", 1e-6)
      .attr("d", function(d) { return line(d.values); });

    t.select("text")
      .attr("transform", function(d) { d = d.values[d.values.length - 1]; return "translate(" + (width - 60) + "," + y(d.raw_data / 2 + d.raw_data0) + ")"; });

    // setTimeout(overlappingArea, duration + delay);
  }

  function overlappingArea() {
    var g = svg.selectAll(".sensor_id");

    line
      .y(function(d) { return y(d.raw_data0 + d.raw_data); });

    g.select(".line")
      .attr("d", function(d) { return line(d.values); });

    y
      .domain([0, d3.max(sensor_ids.map(function(d) { return d.maxRawData; }))])
      .range([height, 0]);

    area
      .y0(height)
      .y1(function(d) { return y(d.raw_data); });

    line
      .y(function(d) { return y(d.raw_data); });

    var t = g.transition()
      .duration(duration);

    t.select(".line")
      .style("stroke-opacity", 1)
      .attr("d", function(d) { return line(d.values); });

    t.select(".area")
      .style("fill-opacity", .5)
      .attr("d", function(d) { return area(d.values); });

    t.select("text")
      .attr("dy", ".31em")
      .attr("transform", function(d) { d = d.values[d.values.length - 1]; return "translate(" + (width - 60) + "," + y(d.raw_data) + ")"; });

    svg.append("line")
      .attr("class", "line")
      .attr("x1", 0)
      .attr("x2", width - 60)
      .attr("y1", height)
      .attr("y2", height)
      .style("stroke-opacity", 1e-6)
      .transition()
      .duration(duration)
      .style("stroke-opacity", 1);

    // setTimeout(groupedBar, duration + delay);
  }

  function groupedBar() {
    x = d3.scale.ordinal()
      .domain(sensor_ids[0].values.map(function(d) { return d.created_at; }))
      .rangeBands([0, width - 60], .1);

    var x1 = d3.scale.ordinal()
      .domain(sensor_ids.map(function(d) { return d.key; }))
      .rangeBands([0, x.rangeBand()]);

    var g = svg.selectAll(".sensor_id");

    var t = g.transition()
      .duration(duration);

    t.select(".line")
      .style("stroke-opacity", 1e-6)
      .remove();

    t.select(".area")
      .style("fill-opacity", 1e-6)
      .remove();

    g.each(function(p, j) {
      d3.select(this).selectAll("rect")
        .data(function(d) { return d.values; })
        .enter().append("rect")
        .attr("x", function(d) { return x(d.created_at) + x1(p.key); })
        .attr("y", function(d) { return y(d.raw_data); })
        .attr("width", x1.rangeBand())
        .attr("height", function(d) { return height - y(d.raw_data); })
        .style("fill", color(p.key))
        .style("fill-opacity", 1e-6)
        .transition()
        .duration(duration)
        .style("fill-opacity", 1);
    });

    // setTimeout(stackedBar, duration + delay);
  }

  function stackedBar() {
    x.rangeRoundBands([0, width - 60], .1);

    var stack = d3.layout.stack()
      .values(function(d) { return d.values; })
      .x(function(d) { return d.created_at; })
      .y(function(d) { return d.raw_data; })
      .out(function(d, y0, y) { d.raw_data0 = y0; })
      .order("reverse");

    var g = svg.selectAll(".sensor_id");

    stack(sensor_ids);

    y
      .domain([0, d3.max(sensor_ids[0].values.map(function(d) { return d.raw_data + d.raw_data0; }))])
      .range([height, 0]);

    var t = g.transition()
      .duration(duration / 2);

    t.select("text")
      .delay(sensor_ids[0].values.length * 10)
      .attr("transform", function(d) { d = d.values[d.values.length - 1]; return "translate(" + (width - 60) + "," + y(d.raw_data / 2 + d.raw_data0) + ")"; });

    t.selectAll("rect")
      .delay(function(d, i) { return i * 10; })
      .attr("y", function(d) { return y(d.raw_data0 + d.raw_data); })
      .attr("height", function(d) { return height - y(d.raw_data); })
      .each("end", function() {
        d3.select(this)
          .style("stroke", "#fff")
          .style("stroke-opacity", 1e-6)
          .transition()
          .duration(duration / 2)
          .attr("x", function(d) { return x(d.created_at); })
          .attr("width", x.rangeBand())
          .style("stroke-opacity", 1);
      });

    // setTimeout(transposeBar, duration + sensor_ids[0].values.length * 10 + delay);
  }

  function transposeBar() {
    x
      .domain(sensor_ids.map(function(d) { return d.key; }))
      .rangeRoundBands([0, width], .2);

    y
      .domain([0, d3.max(sensor_ids.map(function(d) { return d3.sum(d.values.map(function(d) { return d.raw_data; })); }))]);

    var stack = d3.layout.stack()
      .x(function(d, i) { return i; })
      .y(function(d) { return d.raw_data; })
      .out(function(d, y0, y) { d.raw_data0 = y0; });

    stack(d3.zip.apply(null, sensor_ids.map(function(d) { return d.values; }))); // transpose!

    var g = svg.selectAll(".sensor_id");

    var t = g.transition()
      .duration(duration / 2);
  }
}
