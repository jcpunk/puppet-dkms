# frozen_string_literal: true

require 'spec_helper'

describe 'dkms' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge({ 'architecture' => 'x86_64' }) }

      context 'with defaults' do
        it { is_expected.to compile }
        it { is_expected.to contain_package('dkms').with_ensure('installed') }
        it { is_expected.to have_dkms__kernel_module_resource_count(0) }

        if os_facts[:os]['family'] == 'Debian'
          it { is_expected.not_to contain_service('dkms.service') }

          if os_facts[:os]['name'] == 'Ubuntu'
            it { is_expected.to contain_package('linux-headers-generic').with_ensure('installed') }
          else
            it { is_expected.to contain_package('linux-headers-amd64').with_ensure('installed') }
          end
        else
          it { is_expected.to contain_package('kernel-devel').with_ensure('installed') }
          it {
            is_expected.to contain_service('dkms.service')
              .with_ensure('running')
              .with_enable(true)
              .with_require('Class[Dkms::Install]')
          }
          if os_facts[:os]['family'] == 'RedHat'
            it { is_expected.to contain_package('kernel-headers').with_ensure('installed') }
          end
        end
      end

      context 'with arguments' do
        let(:params) do
          {
            'package_manage' => false,
            'kernel_devel_package_manage' => false,
            'service_manage' => false,
            'kernel_modules' => { 'testpkg' => { 'kmod_version' => 1 }, 'otherpkg' => { 'kmod_version' => 'v1.2b' } }
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_package_resource_count(0) }
        it { is_expected.to have_service_resource_count(0) }
        it { is_expected.to have_dkms__kernel_module_resource_count(2) }
      end
    end
  end
end
