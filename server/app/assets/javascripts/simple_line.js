setup_canvas = function() {
  update_units = function() {
    $('.y-axis-label').text($(".line-color" + $(this).parent().attr('class').substring(11)).parent().text());
  };

  update_custom_signals_display = function() {
    if (config.custom_signals == undefined) {
      config.custom_signals = [];
    }
    $('.custom-signals').html('');
    config.custom_signals.forEach(function(formula, index) {
      $('.custom-signals').append('div.form-group').html("[" + index + "]: " + formula);
    });
  }

  add_custom_signal = function() {
    id = config.custom_signals.length;
    formula = window.prompt('Please enter a formula', '');
    config.custom_signals[id] = formula;
    save_config();
    update_custom_signals_display();
  };

  $('#refresh-interval').on('change', function(){
    clearInterval(auto_refresh);
    auto_refresh = setInterval(load_data, $(this).val() * 1000);
    config.refresh_rate = $(this).val();
    save_config();
  });

  $('#time-from').on('change', function(){
    config.time_from = $(this).val();
    save_config();
  });

  $('#time-to').on('change', function(){
    config.time_to = $(this).val();
    save_config();
  });

  $('#limit').on('change', function(){
    config.limit = $(this).val();
    save_config();
  });

  $('.add-custom-signal').on('click', function() {
    add_custom_signal();
    save_config();
  });

  // Visible plots
  $('.visible-sensors input[type=checkbox]').on('change', function(){
    id = $(this).val();
    config.plots[id] = {id: id, color: $(this).parent().find("input[type=color]").val(), visible: $(this).is(":checked")};
    if($(this).is(":checked")){
      // Add this plot to the config.plots array
      svg.append("path") // Add the plot to the graph
        .attr("class", "line" + $(this).val())
        .attr('style', 'stroke:' + $(this).parent().find('input[type=color]').val());
      svg.append("g") // Add the new data points to the graph
        .attr("class", "data-points" + $(this).val());
    } else {
      config.plots[$(this).val()]['visible'] = false;
      $("svg path.line" + $(this).val()).remove();
      $("svg g.data-points" + $(this).val()).remove();
    }
    save_config();
    load_data();
  });

  // Plot colors
  $('.visible-sensors input[type=color]').on('change', function(){
    checkbox = $(this).parent().find('input[type=checkbox]');
    if (config.plots[checkbox.val()] == undefined){
      config.plots[checkbox.val()] = {id: checkbox.val(), color: $(this).val(), visible: false};
    }
    if (checkbox.is(':checked')) {
      $('svg path.line' + checkbox.val()).attr('style', 'stroke:' + $(this).val());
    }
    config.plots[checkbox.val()].color = $(this).val();
    save_config();
  });

  save_config = function() {
    $.ajax(window.location.pathname + ".json", {method: 'PATCH', data: {dashboard: {config: JSON.stringify(config)}}});
  }

  // Set the dimensions of the canvas / graph
  var margin = {top: 50, right: 10, bottom: 30, left: 70},
  width = 1150 - margin.left - margin.right,
  height = 550 - margin.top - margin.bottom;

  var date_formatter = d3.time.format("%d-%b-%y");

  // Set the axis pixel ranges
  var x = d3.time.scale().range([0, width]),
  y = d3.scale.linear().range([height, 0]);

  // Define the axes
  var xAxis = d3.svg.axis()
    .scale(x)
    .innerTickSize(-height)
    .orient("bottom"),
  yAxis = d3.svg.axis()
    .scale(y)
    .innerTickSize(-width)
    .orient("left");

  // Define the line
  var valueline = d3.svg.line()
    .x(function(d) { return x(d.x); })
    .y(function(d) { return y(d.y); });

  // Add the svg canvas
  var svg = d3.select('.dashboard-graph')
    .append("svg")
      .attr("width", '100%')
      .attr("height", height + margin.top + margin.bottom);

  // Add a group for control buttons (AutoRefresh, Config, etc.)
  var control = svg.append("g")
    .attr("class", "control-svg");

  var auto_refresh;
  var btn_auto_refresh = control.append("text")
    .style('font-family', 'FontAwesome')
    .html("&#xF01E Auto Refresh")
    .attr('width', 40)
    .attr('height', 40)
    .attr('x', 5)
    .attr('y', 23)
    .attr('fill', 'green')
    .on('click', function() {
      if ($(this).attr('fill') != 'green') {
        auto_refresh = setInterval(load_data, $('#refresh-interval').val() * 1000);
        $(this).attr('fill','green');
      } else {
        clearInterval(auto_refresh);
        $(this).attr('fill','black');
      }
    });

  var btn_auto_refresh = control.append("text")
    .style('font-family', 'FontAwesome')
    .html("&#xF01E Refresh Manually")
    .attr('width', 40)
    .attr('height', 40)
    .attr('x', 5)
    .attr('y', 43)
    .on('click', function() {
      load_data();
    });

  var btn_config = control.append("text")
    .style('font-family', 'FontAwesome')
    .html("&#xF044 Configure")
    .attr('width', 40)
    .attr('height', 40)
    .attr('x', 160)
    .attr('y', 23)
    // .attr('fill', 'green')
    .on('click', function() {
      $('.control-panel').toggle();
      if ($(this).attr('fill') != 'green') {
        $(this).attr('fill','green');
      } else {
        $(this).attr('fill','black');
      }
    });

  svg = svg.append("g")
    .attr("transform", 
      "translate(" + margin.left + "," + margin.top + ")");

  // Add grid lines
  svg.append("g")
    .attr("class", "grid-lines")

  // Add a title
  var title = svg.append("text")
    .attr("class", "chart-title")
    .attr("text-anchor", "middle")
    .attr("x", width / 2)
    .attr("y", -10)
    .text(graph_title);

  // Add X axis label
  svg.append("text")
    .attr("class", "x-axis-label")
    .attr("text-anchor", "end")
    .attr("x", width)
    .attr("y", height - 6)
    .text("Time");

  // Add Y axis label
  svg.append("text")
    .attr("class", "y-axis-label")
    .attr("text-anchor", "end")
    .attr("y", 6)
    .attr("dy", ".75em")
    .attr("transform", "rotate(-90)")
    .text("");

  // Add the X Axis
  svg.append("g")
    .attr("class", "x-axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis);

  // Add the Y Axis
  svg.append("g")
    .attr("class", "y-axis")
    .call(yAxis);

  var legend = svg.append("g")
    .attr("class", "legend")
    .attr("transform", "translate(" + width + "," + 0 + ")")
    .append("text")
    .text("Legend")

  legend.append("tspan")
    .attr("class", "legend")
    .attr("x", 0)
    .attr("dy", 20)
    .text($('.sensor-select :selected').text());

  load_data = function(){
    // console.log(Date() + ' load_data()');

    $('.legend').text($('input[type=checkbox]:checked').map(function(e,v){return $(v).attr('name')}));

    var start_time = Date.now();

    // Get the data
    available_plots = $.map($('input[type=checkbox]:checked'),function(e) { return $(e).val() });
    d3.json( encodeURI(
          "/sensors/" +
          available_plots.join(',') +
          "/data_points.json?from=" + $('#time-from').val() + "&to=" + $('#time-to').val() + "&limit=" + $('#limit').val()), function(error, data) {
      data = data.data_points;

      if (data.length > 0) {
        data.forEach(function(d) {
          d.x = new Date(d.timestamp);
          d.y = +d.data;
        });

        data.reverse();
      }

      draw_data(data);
    });

    draw_data = function(data) {
      all_sensor_ids = $.unique(data.map(function(e) { return e.sensor_id }));
      // console.log("draw_data");
      // Scale the range of the data
      x.domain(d3.extent(data, function(d) { return d.x; }));
      y.domain(d3.extent(data, function(d) { return d.y; }));

      xAxis.scale(x);
      yAxis.scale(y);

      d3.select("g.x-axis").call(xAxis);
      d3.select("g.y-axis").call(yAxis);

      all_sensor_ids.forEach(function(id) {
        sensor_data = data.filter(function(e){return e.sensor_id == id});
        // Update or add the lines
        var line = svg.select("path.line" + id)
          .data(valueline(sensor_data || []) || [])
          .attr("d", valueline(sensor_data || []) || '');

        // Add/update data points
        var data_points = svg.select("g.data-points" + id)
          .selectAll("circle")
          .data(sensor_data);
        data_points
            .attr("title", function(d){ return d.y})
            .attr("cx", function(d){ return x(d.x) })
            .attr("cy", function(d){ return y(d.y) });
        data_points
          .enter().append("circle")
              .attr("class", "data-point")
              .attr("title", function(d){ return d.y})
              .attr("cx", function(d){ return x(d.x) })
              .attr("cy", function(d){ return y(d.y) })
              .attr("fill", $('.line-color' + id).val())
              .attr("stroke", $('.line-color' + id).val())
              .attr("r", 2);
        data_points.exit().remove();

        data_points.on('click', update_units);

        $("svg circle").tipsy({
          gravity: 's',
          fade: true
        });
      });
    }
  }

  auto_refresh = setInterval(load_data, $('#refresh-interval').val() * 1000);
  load_data();
  update_custom_signals_display();
}
