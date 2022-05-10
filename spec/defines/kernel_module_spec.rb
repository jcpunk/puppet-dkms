# frozen_string_literal: true

require 'spec_helper'

describe 'dkms::kernel_module' do
  let(:pre_condition) do
    [
      'include ::dkms',
    ]
  end
  let(:title) { 'namevar' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge({ 'kernelrelease' => '2.6.32' }) }

      context 'with minimal args' do
        let(:params) do
          {
            'kmod_version' => 1,
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_exec('dkms add -m namevar -v 1')
            .with_require('Class[Dkms::Install]')
            .with_notify(nil)
        }
        it { is_expected.not_to contain_exec('dkms build -m namevar -v 1 -k 2.6.32') }
        it { is_expected.not_to contain_exec('dkms install -m namevar -v 1 -k 2.6.32') }
        it { is_expected.not_to contain_exec('dkms remove -m namevar -v 1 -k 2.6.32') }
      end

      context 'with args to build' do
        let(:params) do
          {
            'kmod_version' => 'v0.1.1',
            'kmod_name' => 'unit_test',
            'ensure' => 'built',
            'on_kernel' => 'all',
            'build_timeout' => 10,
            'use_autoinstall' => false,
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_exec('dkms add -m unit_test -v v0.1.1')
            .with_require('Class[Dkms::Install]')
            .with_notify(nil)
        }
        it {
          is_expected.to contain_exec('dkms build -m unit_test -v v0.1.1 --all')
            .with_require(['Exec[dkms add -m unit_test -v v0.1.1]', 'Class[Dkms::Install]'])
            .with_timeout(10)
            .with_notify(nil)
        }
        it { is_expected.not_to contain_exec('dkms install -m unit_test -v v0.1.1 --all') }
        it { is_expected.not_to contain_exec('dkms remove -m unit_test -v v0.1.1 --all') }
      end

      context 'with args to install and notify' do
        let(:params) do
          {
            'kmod_version' => 'v0.1.1',
            'kmod_name' => 'unit_test',
            'ensure' => 'installed',
            'on_kernel' => 'ALL',
            'use_autoinstall' => true,
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_exec('dkms add -m unit_test -v v0.1.1')
            .with_require('Class[Dkms::Install]')
            .with_notify('Class[Dkms::Autoinstall]')
        }
        it {
          is_expected.to contain_exec('dkms build -m unit_test -v v0.1.1 --all')
            .with_require(['Exec[dkms add -m unit_test -v v0.1.1]', 'Class[Dkms::Install]'])
            .with_notify('Class[Dkms::Autoinstall]')
        }
        it {
          is_expected.to contain_exec('dkms install -m unit_test -v v0.1.1 --all')
            .with_require(['Exec[dkms build -m unit_test -v v0.1.1 --all]', 'Class[Dkms::Install]'])
            .with_notify('Class[Dkms::Autoinstall]')
        }
        it { is_expected.not_to contain_exec('dkms remove -m unit_test -v v0.1.1 --all') }
      end

      context 'with args to remove' do
        let(:params) do
          {
            'kmod_version' => 'v0.1.1',
            'kmod_name' => 'unit_test',
            'ensure' => 'absent',
            'on_kernel' => 'all',
            'use_autoinstall' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_exec('dkms add -m unit_test -v v0.1.1') }
        it { is_expected.not_to contain_exec('dkms build -m unit_test -v v0.1.1 --all') }
        it { is_expected.not_to contain_exec('dkms install -m unit_test -v v0.1.1 --all') }
        it {
          is_expected.to contain_exec('dkms remove -m unit_test -v v0.1.1 --all')
            .with_require('Class[Dkms::Install]')
            .with_notify(nil)
        }
      end

      context 'with args to remove and notify' do
        let(:params) do
          {
            'kmod_version' => 'v0.1.1',
            'kmod_name' => 'unit_test',
            'ensure' => 'absent',
            'use_autoinstall' => true,
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_exec('dkms add -m unit_test -v v0.1.1') }
        it { is_expected.not_to contain_exec('dkms build -m unit_test -v v0.1.1 -k 2.6.32') }
        it { is_expected.not_to contain_exec('dkms install -m unit_test -v v0.1.1 -k 2.6.32') }
        it {
          is_expected.to contain_exec('dkms remove -m unit_test -v v0.1.1 -k 2.6.32')
            .with_require('Class[Dkms::Install]')
            .with_notify('Class[Dkms::Autoinstall]')
        }
      end
    end
  end
end
