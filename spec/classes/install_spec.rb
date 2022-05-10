# frozen_string_literal: true

require 'spec_helper'

describe 'dkms::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        it { is_expected.to compile }
        it { is_expected.to contain_package('dkms').with_ensure('installed') }

        if os_facts[:os]['family'] == 'Debian'
          if os_facts[:os]['name'] == 'Ubuntu'
            it { is_expected.to contain_package('linux-headers-generic').with_ensure('installed') }
          else
            it { is_expected.to contain_package('linux-headers-amd64').with_ensure('installed') }
          end
        else
          it { is_expected.to contain_package('kernel-devel').with_ensure('installed') }
          if os_facts[:os]['family'] == 'RedHat'
            it { is_expected.to contain_package('kernel-headers').with_ensure('installed') }
          end
        end
      end
    end
  end
end
