require "unienv/version"
require "yaml"
require "tmpdir"
require "open-uri"


module UniEnv
  def self.sh(cmd)
    print "exec: #{cmd}\n"
    system cmd
    if $? != 0
      raise "ERROR: #{$?.to_i}"
    end
  end
  def self.editor_path
    "#{$project_path}/Assets/Editor"
  end
  def self.has_editor?
    Dir.exist?(self.editor_path)
  end
  def self.find_project
    return unless $project_path.nil?
    dirs = Dir.glob("**/Assets")
    dirs.each do |d|
      d = d.sub(/(\/)?Assets$/, '')
      if Dir.exist?("#{d}/ProjectSettings")
        $project_path = File.expand_path(d)
      end
    end
  end
  def self.check_target(target)
    cand = [ 'ios', 'android' ]
    cand.select! { |c| c =~ /^#{target}/i }
    return cand[0] if cand.size == 1
    return nil
  end
  def self.check_config(config)
    cand = [ 'development', 'release', 'distribution' ]
    cand.select! { |c| c =~ /^#{config}/i }
    return cand[0] if cand.size == 1
    return nil
  end





  def self.load_config
    txt = File.read("#{ASSETS_PATH}/unity_versions.yml")
    YAML.load(txt)
  end


  def self.enum_installed
    unis = Dir.glob('/Applications/Unity*')
    list = {}
    unis.each do |uni|
      if File.basename(uni) =~ /\AUnity(.+)\Z/
        ver = $1
        list[ver] = uni
      end
    end
    list
  end

  def self.search_version(config, name)
    vers = []
    config['version'].each do |k, v|
      vers << k if k.include?(name)
    end
    vers
  end
  def self.editor_uri(config, version)
    config['version'][version]['editor']
  end
  def self.standard_assets_uri(config, version)
    config['version'][version]['standard_assets']
  end

  def self.tmpdir
    Dir.tmpdir + "/unienv"
  end
  def self.make_tmpdir
    FileUtils.mkdir_p(tmpdir)
  end
  def self.clean_tmpdir
    FileUtils.remove_entry_secure(tmpdir)
  end
  def self.make_cache_path(type, version)
    "#{tmpdir}/#{type}-#{version}.pkg"
  end
  def self.make_editor_cache_path(version)
    make_cache_path("Unity", version)
  end
  def self.make_standard_assets_cache_path(version)
    make_cache_path("StandardAssets", version)
  end
  def self.find_cache(type, version)
    Dir.glob(make_cache_path(type, version))
  end
  def self.find_editor_cache(version)
    find_cache("Unity", version)
  end
  def self.find_standard_assets_cache(version)
    find_cache("StandardAssets", version)
  end

  def self.download(uri, path)
    totalsize = nil
    size = 0
    progress = 0
    sio =
      OpenURI.open_uri(
        uri,
        {
          :content_length_proc => lambda { |sz|
            totalsize = sz
            print "total: #{sz / 1024}KB\n"
          },
          :progress_proc => lambda { |sz|
            unless totalsize.nil?
              size = sz
              rate = ((size.to_f / totalsize.to_f) * 10).to_i
              if rate > progress
                print ". #{sz / 1024}KB\n"
                progress = rate
              end
            end
          },
        }
      )
    File.open(path, "w+") do |f|
      f.write(sio.read)
    end
  end


end




command :list do |c|
  c.syntax = 'unienv list'
  c.summary = 'display unity versions'
  c.option '--local', 'specify .unitypackage name'
  c.action do |args, options|
    if options.local
      list = UniEnv.enum_installed
      print "local installed:\n"
      list.sort.reverse.each do |k, v|
        print "  #{k}\n"
      end
    else
      config = UniEnv.load_config
      config['version'].sort.reverse.each do |k, v|
        print "  #{k}\n"
      end
    end
  end
end


command :install do |c|
  c.syntax = 'unienv install [version]'
  c.summary = 'install specified version'
  c.action do |args, options|
    raise 'specify version' unless args.size != 0
    config = UniEnv.load_config
    candidates = UniEnv.search_version(config, args[0])
    raise "ambiguous versions. #{candidates}" unless candidates.size == 1
    version = candidates[0]

    UniEnv.make_tmpdir
    editor_cache = UniEnv.find_editor_cache(version)
    standard_assets_cache = UniEnv.find_standard_assets_cache(version)
    if editor_cache.empty?
      UniEnv.download(UniEnv.editor_uri(config, version), UniEnv.make_editor_cache_path(version))
      editor_cache = UniEnv.find_editor_cache(version)
    end
    if standard_assets_cache.empty?
      UniEnv.download(UniEnv.standard_assets_uri(config, version), UniEnv.make_standard_assets_cache_path(version))
      standard_assets_cache = UniEnv.find_standard_assets_cache(version)
    end

    p editor_cache
    p standard_assets_cache
    p candidates
    #UniEnv.clean_tmpdir(tmppath)

    UniEnv.sh "installer -package #{editor_cache[0]} -target /"
    UniEnv.sh "installer -package #{standard_assets_cache[0]} -target /"

    FileUtils.mv("/Applications/Unity", "/Applications/Unity#{version}")
  end
end

command :select do |c|
  c.syntax = 'unienv select [version]'
  c.summary = 'select version'
  c.action do |args, options|
    list = UniEnv.enum_installed
    raise 'specify version' if args.size != 1
    version = args[0]
    raise "not installed #{version}" if list[version].nil?
    link = '/Applications/Unity'
    FileUtils.rm(link) if File.exist?(link)
    sleep 4
    FileUtils.symlink("#{list[version]}", link, { :force => true })





  end
end













__END__



command :showlog do |c|
  c.syntax = 'ubb showlog'
  c.summary = 'show Unity Editor log'
  c.action do |args, options|
    log = '~/Library/Logs/Unity/Editor.log'
    UniEnv.sh "less #{log}"
  end
end
alias_command :log, :showlog

command :export do |c|
  UniEnv.find_project
  c.syntax = 'ubb export [options]'
  c.summary = 'export .unitypackage'
  c.description = 'hoge'
  c.example 'export some folders to unitypackage', 'ubb export --project path/to/unityproject --output some.unitypackage Plugins/Something Resources/Something'
  c.option '--output FILENAME', String, 'specify .unitypackage name'
  c.action do |args, options|
    raise 'specify output filename' if options.output.nil?
    output = (options.output !~ /\.unitypackage$/)? options.output + ".unitypackage" : options.output
    output = File.expand_path(output)
    paths = args.map { |pt| "Assets/#{pt}" }.join(' ')
    UniEnv.sh "#{$unity_app_path} -batchmode -projectPath #{$project_path} -exportPackage #{paths} #{output} -quit"
  end
end

command :import do |c|
  UniEnv.find_project
  c.syntax = 'ubb import [package]'
  c.summary = 'import .unitypackage'
  c.description = 'hoge'
  c.example 'import some unitypackage', 'ubb import --project path/to/unityproject some.unitypackage'
  c.action do |args, options|
    raise 'specify unitypackage file' if args.size == 0
    raise 'too many unitypackage files' if args.size > 1
    input = args[0]
    raise "#{input} does not exist" unless File.exist?(input)
    UniEnv.sh "#{$unity_app_path} -batchmode -projectPath #{$project_path} -importPackage #{input} -quit"
  end
end

command :build do |c|
  UniEnv.find_project
  c.syntax = 'ubb build [options]'
  c.summary = 'build project'
  c.description = 'hoge'
  c.example 'build project', 'ubb build --project path/to/unityproject --output path/to/outputproject'
  c.option '--output PATH', String, 'specify output path'
  c.option '--target TARGET', String, 'specify build target (ios|android)'
  c.option '--config COFIGURATION', String, 'specify build configuration (development|release|distribution)'
  c.action do |args, options|
    options.default :config => 'development'
    raise 'specify output path' if options.output.nil?
    raise 'specify target' if options.target.nil?
    output = File.expand_path(options.output)
    target = UniEnv.check_target(options.target)
    config = UniEnv.check_config(options.config)
    raise "could not recognize a target: \"#{options.target}\"" if target.nil?
    begin
      has = UniEnv.has_editor?
      editor_path = UniEnv.editor_path
      src = "#{LIB_PATH}/assets/UniEnvBuild.cs"
      dst = "#{editor_path}/UniEnvBuild.cs"
      FileUtils.mkdir_p editor_path unless has
      noop = false
      if File.exist?(dst)
        noop = true
        raise 'build script has already existed'
      end
      cs = File.read(src)
      csfile = File.open(dst, "w+")
      csfile.write(ERB.new(cs).result binding)
      csfile.flush
      UniEnv.sh "#{$unity_app_path} -batchmode -projectPath #{$project_path} -quit -executeMethod Build.PerformBuild_#{target} -config #{config}"
    ensure
      unless noop
        FileUtils.rm_f "#{editor_path}/UniEnvBuild.cs"
        FileUtils.rm_f "#{editor_path}/UniEnvBuild.cs.meta"
        unless has
          FileUtils.rm_rf editor_path
          FileUtils.rm_f "#{editor_path}.meta"
        end
      end
    end
  end
end