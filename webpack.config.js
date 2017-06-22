var ExtractTextPlugin = require("extract-text-webpack-plugin");
var CopyWebpackPlugin = require("copy-webpack-plugin");
var phoenixStaticPath = "./web/static/js"

module.exports = {
  entry: {
    main: phoenixStaticPath + "/../css/appscss.js",
    app: phoenixStaticPath + "/app.js",
    'f_calendar': phoenixStaticPath + "/f_calendar/f_calendar.js",
    "program_page": phoenixStaticPath + "/program_page/program_page.js",
    "login": phoenixStaticPath + "/page/login.js",
    "job_template": phoenixStaticPath + "/job_template/job_template.js",
    "avatar": phoenixStaticPath + "/avatar/avatar.js"
  },

  output: {
    path: "./priv/static/",
    filename: "js/[name].js"
  },

  module: {
    loaders: [{
      test: /\.js$/,
      exclude: /node_modules/,
      loader: "babel",
      include: __dirname,
      query: {
        presets: ["es2015"]
      }
    }, {
      test: /\.css$/,
      loader: 'style!css'
    },{
      test: /\.scss$/,
      loader: ExtractTextPlugin.extract("style", "css!sass")
    },{
      test: /\.jsx?$/,
      exclude: /(node_modules|bower_components)/,
      loader: 'babel-loader',
      query: {
        plugins: ['recharts'],
        presets: ['es2015', 'react']
      }
    },{
      test: /\.less$/,
      loader: 'style!css!less'
    },{
      test: /\.json$/,
      loader: 'json-loader'
    }]
  },

  resolve: {
    modulesDirectories: [ "node_modules", __dirname + "/web/static/js" ],
    alias: {
      Chartist: "chartist/dist/chartist.js",
      jQuery: "jquery/dist/jquery.js"
    },
  },

  plugins: [
    new ExtractTextPlugin("css/app.css"),
    new CopyWebpackPlugin([{ from: "./web/static/assets" }])
  ],

};
