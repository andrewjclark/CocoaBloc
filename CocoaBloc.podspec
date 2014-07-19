Pod::Spec.new do |s|
    s.name = 'CocoaBloc'
    s.version = '0.0.1'
    s.authors = { 'John Heaton' => 'pikachu@stagebloc.com',
                  'Dave Skuza'  => 'neo@stagebloc.com' }
    s.social_media_url = 'https://twitter.com/StageBloc'
    s.homepage = 'https://github.com/stagebloc/CocoaBloc'
    s.summary = 'StageBloc Cocoa SDK'
    s.description = 'An Objective-C(Swift-compatible) library for interacting with StageBloc, and displaying StageBloc information/content to users.'
    s.dependency 'ReactiveCocoa'
    s.requires_arc = true
    s.source_files = 'Projects/Library/CocoaBloc/CocoaBloc.h'
    s.private_header_files = 'Projects/Library/CocoaBloc/Internal/*.h'
    s.ios.deployment_target = '7.0'
    s.osx.deployment_target = '10.9'

    s.subspec 'API' do |ss|
      ss.dependency 'AFNetworking'
      ss.dependency 'AFNetworking-RACExtensions'
      ss.dependency 'CocoaBloc/Models'
      ss.header_mappings_dir = 'Projects/Library/CocoaBloc/API'
      ss.prefix_header_contents = '#import <ReactiveCocoa/RACEXTScope.h>'
      ss.source_files = 'Projects/Library/CocoaBloc/API/*.{h,m}'
    end

    s.subspec 'Models' do |ss|
      ss.dependency 'Mantle'
      ss.header_mappings_dir = 'Projects/Library/CocoaBloc/Models'
      ss.source_files = 'Projects/Library/CocoaBloc/{Models,Internal/Categories}/*.{h,m}'
      ss.private_header_files = 'Projects/Library/CocoaBloc/Internal/**/*.h'
    end

    s.subspec 'UI' do |ss|
      ss.dependency 'PureLayout'
      ss.source_files = 'Projects/Library/CocoaBloc/UI/*.{h,m}'
    end
end
