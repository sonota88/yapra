#!/usr/bin/env ruby -wKU
$KCODE='u'
require 'yaml'
require 'optparse'
require 'kconv'
require 'pathname'
require 'base64'

YAPRA_ROOT = File.dirname(__FILE__)

$:.insert(0, *[
  File.join(YAPRA_ROOT, 'lib-plugins'),
  File.join(YAPRA_ROOT, 'lib')
])

legacy_plugin_directory_paths = [
  Pathname.new(YAPRA_ROOT) + 'legacy_plugins',
  Pathname.new(YAPRA_ROOT) + 'plugins'
]

require 'yapra/runtime'
require 'yapra/config'
require 'yapra/legacy_plugin/registry_factory'

Version     = '0.1.0'
mode        = 'compatible'
config_file = "config.yaml"
loglebel    = nil
opt = OptionParser.new
opt.on("-c", "--configfile CONFIGFILE") {|v| config_file = v }
opt.on("-p", "--plugindir PLUGINDIR") {|v| legacy_plugin_directory_paths << v }
opt.on("-m", "--mode MODE", 'compatible / advance') { |v| mode = v }
opt.on("--log-level LOGLEVEL", 'fatal / error / warn / info / debug') { |v| loglebel = v }
# opt.on("-u", "--pluginusage PLUGINNAME") {|v| $plugins[v].source.gsub(/^## ?(.*)/){ puts $1 }; exit }
# opt.on("-l", "--listplugin") { $plugins.keys.sort.each{|k| puts k }; exit }
# opt.on("-w", "--where") { puts(Pathname.new(__FILE__).parent + "plugin"); exit }
opt.parse!

legacy_plugin_registry_factory = Yapra::LegacyPlugin::RegistryFactory.new(legacy_plugin_directory_paths, mode)
config = YAML.load(File.read(config_file).toutf8.gsub(/base64::([\w+\/]+=*)/){ Base64.decode64($1) })
config = Yapra::Config.new(config)
config.env.update({
  'log' => {
    'level' => loglebel
  }
}) if loglebel
yapra = Yapra::Runtime.new(
  config,
  legacy_plugin_registry_factory
)
yapra.execute()
