require 'spec_helper'

describe 'auditd::audisp' do
  context 'supported operating systems' do
    audit_v2 = ['CentOS7', 'Debian10', 'RedHat7', 'Scientific7', 'Ubuntu20.04', 'Ubuntu18.04']
    audit_v3 = ['AlmaLinux8', 'Debian11', 'RedHat8', 'Rocky8', 'Ubuntu22.04']

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        test_os = [facts[:os]['name'], facts[:os]['release']['major']].join('')

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('auditd::audisp') }
        it { is_expected.to contain_package('audispd-plugins') }

        it {
          is_expected.to contain_file('/sbin/audispd').only_with(
            'ensure'  => 'file',
            'mode'    => '0750',
          )
        }

        if audit_v2.include?(test_os)
          it { is_expected.to contain_file('/etc/audisp/').with_ensure('directory') }
          it { is_expected.to contain_file('/etc/audisp/plugins.d').with_ensure('directory') }
          it { is_expected.to contain_file('/etc/audisp/audispd.conf') }
          it {
            is_expected.to contain_file('auditd-audisp-plugin-syslog.conf').with(
              path: '/etc/audisp/plugins.d/syslog.conf',
            )
          }

          if facts[:os]['family'] == 'Debian'
            it { is_expected.to contain_auditd__plugin('af_unix') }
            it { is_expected.to contain_auditd__plugin('au-prelude') }
            it { is_expected.to contain_auditd__plugin('au-remote') }
            it { is_expected.to contain_auditd__plugin('audispd-zos-remote') }
            it { is_expected.to contain_auditd__plugin('syslog') }
            it { is_expected.to contain_file('auditd-audisp-plugin-af_unix.conf') }
            it { is_expected.to contain_file('auditd-audisp-plugin-au-prelude.conf') }
            it { is_expected.to contain_file('auditd-audisp-plugin-au-remote.conf') }
            it { is_expected.to contain_file('auditd-audisp-plugin-audispd-zos-remote.conf') }
            it { is_expected.to contain_file('auditd-audisp-plugin-syslog.conf') }
          end
        end

        if audit_v3.include?(test_os)
          it { is_expected.not_to contain_file('/etc/audisp/').with_ensure('directory') }
          it { is_expected.not_to contain_file('/etc/audisp/plugins.d').with_ensure('directory') }
          it { is_expected.not_to contain_file('/etc/audisp/audispd.conf') }
          it { is_expected.not_to contain_file('auditd-audisp-plugin-syslog.conf') }
          if facts[:os]['family'] == 'Debian'
            it { is_expected.to contain_file('auditd-auditd-plugin-af_unix.conf') }
            it { is_expected.to contain_file('auditd-auditd-plugin-au-remote.conf') }
            it { is_expected.to contain_file('auditd-auditd-plugin-audispd-zos-remote.conf') }
          end
        end
      end
    end
  end
end
