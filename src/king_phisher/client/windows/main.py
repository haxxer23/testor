#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  king_phisher/client/windows/main.py
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are
#  met:
#
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following disclaimer
#    in the documentation and/or other materials provided with the
#    distribution.
#  * Neither the name of the project nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

import logging
import weakref

from king_phisher import find
from king_phisher import utilities
from king_phisher.client import dialogs
from king_phisher.client import export
from king_phisher.client import graphs
from king_phisher.client import gui_utilities
from king_phisher.client.widget import extras
from king_phisher.client.windows import plugin_manager
from king_phisher.client.windows import rpc_terminal
from king_phisher.client.windows import campaign_import
from king_phisher.client.windows import compare_campaigns
from king_phisher.client.tabs.campaign import CampaignViewTab
from king_phisher.client.tabs.campaign import CampaignViewGenericTableTab
from king_phisher.client.tabs.mail import MailSenderTab
from king_phisher.constants import ConnectionErrorReason

from gi.repository import Gdk
from gi.repository import GdkPixbuf
from gi.repository import Gtk
import xlsxwriter

if isinstance(Gtk.Widget, utilities.Mock):
	_Gtk_ApplicationWindow = type('Gtk.ApplicationWindow', (object,), {'__module__': ''})
else:
	_Gtk_ApplicationWindow = Gtk.ApplicationWindow

__all__ = ('MainAppWindow',)

class MainMenuBar(gui_utilities.GladeGObject):
	"""
	The main menu bar for the primary application window. This configures any
	optional menu items as well as handles all the menu item signals
	appropriately.
	"""
	dependencies = gui_utilities.GladeDependencies(
		top_level=(
			'StockDeleteImage',
			'StockEditImage',
			'StockHelpImage',
			'StockPropertiesImage',
			'StockStopImage'
		)
	)
	top_gobject = 'menubar'
	def __init__(self, application, window):
		utilities.assert_arg_type(application, Gtk.Application, arg_pos=1)
		utilities.assert_arg_type(window, MainAppWindow, arg_pos=2)
		super(MainMenuBar, self).__init__(application)
		self.window = weakref.proxy(window)
		self._add_accelerators()
		graphs_menu_item = self.gtk_builder_get('menuitem_tools_create_graph')
		if graphs.has_matplotlib:
			graphs_submenu = Gtk.Menu.new()
			for graph_name in graphs.get_graphs():
				graph = graphs.get_graph(graph_name)
				menu_item = Gtk.MenuItem.new_with_label(graph.name_human)
				menu_item.connect('activate', self.signal_activate_tools_show_campaign_graph, graph_name)
				graphs_submenu.append(menu_item)
			graphs_menu_item.set_submenu(graphs_submenu)
			graphs_menu_item.show_all()
		else:
			graphs_menu_item.set_sensitive(False)

	def _add_accelerators(self):
		accelerators = (
			('file_open', Gdk.KEY_o, Gdk.ModifierType.CONTROL_MASK),
			('file_quit', Gdk.KEY_q, Gdk.ModifierType.CONTROL_MASK),
			('tools_rpc_terminal', Gdk.KEY_F1, Gdk.ModifierType.CONTROL_MASK),
			('tools_sftp_client', Gdk.KEY_F2, Gdk.ModifierType.CONTROL_MASK)
		)
		for menu_name, key, modifier in accelerators:
			menu_item = self.gtk_builder_get('menuitem_' + menu_name)
			menu_item.add_accelerator('activate', self.window.accel_group, key, modifier, Gtk.AccelFlags.VISIBLE)

	def signal_activate_edit_configure_campaign(self, _):
		self.application.campaign_configure()

	def signal_activate_edit_delete_campaign(self, _):
		if not gui_utilities.show_dialog_yes_no('Delete This Campaign?', self.application.get_active_window(), 'This action is irreversible, all campaign data will be lost.'):
			return
		self.application.emit('campaign-delete', self.config['campaign_id'])

	def signal_activate_edit_preferences(self, _):
		self.application.show_preferences()

	def signal_activate_edit_stop_service(self, _):
		self.application.stop_remote_service()

	def signal_activate_edit_companies(self, _):
		dialogs.CompanyEditorDialog(self.application).interact()

	def signal_activate_edit_tags(self, _):
		dialogs.TagEditorDialog(self.application).interact()

	def signal_activate_export_campaign_xlsx(self, _):
		self.window.export_campaign_xlsx()

	def signal_activate_export_campaign_xml(self, _):
		self.window.export_campaign_xml()

	def signal_activate_export_message_data(self, _):
		self.window.export_message_data()

	def signal_activate_export_credentials_csv(self, _):
		campaign_tab = self.window.tabs['campaign']
		credentials_tab = campaign_tab.tabs['credentials']
		credentials_tab.export_table_to_csv()

	def signal_activate_export_credentials_msf_txt(self, _):
		dialog = extras.FileChooserDialog('Export Credentials', self.application.get_active_window())
		file_name = self.config['campaign_name'] + '.txt'
		response = dialog.run_quick_save(file_name)
		dialog.destroy()
		if not response:
			return
		destination_file = response['target_path']
		export.campaign_credentials_to_msf_txt(self.application.rpc, self.config['campaign_id'], destination_file)

	def signal_activate_export_messages_csv(self, _):
		campaign_tab = self.window.tabs['campaign']
		messages_tab = campaign_tab.tabs['messages']
		messages_tab.export_table_to_csv()

	def signal_activate_export_visits_csv(self, _):
		campaign_tab = self.window.tabs['campaign']
		visits_tab = campaign_tab.tabs['visits']
		visits_tab.export_table_to_csv()

	def signal_activate_export_visits_geojson(self, _):
		self.window.export_campaign_visit_geojson()

	def signal_activate_import_message_data(self, _):
		self.window.import_message_data()

	def signal_activate_import_campaign_xml(self, _):
		campaign_import.ImportCampaignWindow(self.application)

	def signal_activate_show_campaign_selection(self, _):
		self.application.show_campaign_selection()

	def signal_activate_quit(self, _):
		self.application.quit(optional=True)

	def signal_activate_tools_rpc_terminal(self, _):
		rpc_terminal.RPCTerminal(self.application)

	def signal_activate_tools_clone_page(self, _):
		dialogs.ClonePageDialog(self.application).interact()

	def signal_activate_tools_compare_campaigns(self, _):
		compare_campaigns.CampaignCompWindow(self.application)

	def signal_activate_tools_manage_plugins(self, _):
		plugin_manager.PluginManagerWindow(self.application)

	def signal_activate_tools_sftp_client(self, _):
		self.application.emit('sftp-client-start')

	def signal_activate_tools_show_campaign_graph(self, _, graph_name):
		self.application.show_campaign_graph(graph_name)

	def signal_activate_help_about(self, _):
		dialogs.AboutDialog(self.application).interact()

	def signal_activate_help_templates(self, _):
		utilities.open_uri('https://github.com/securestate/king-phisher-templates')

	def signal_activate_help_wiki(self, _):
		utilities.open_uri('https://github.com/securestate/king-phisher/wiki')

class MainAppWindow(_Gtk_ApplicationWindow):
	"""
	This is the top level King Phisher client window. This is also the parent
	window for most GTK objects.
	"""
	def __init__(self, config, application):
		"""
		:param dict config: The main King Phisher client configuration.
		:param application: The application instance to which this window belongs.
		:type application: :py:class:`.KingPhisherClientApplication`
		"""
		utilities.assert_arg_type(application, Gtk.Application, arg_pos=2)
		super(MainAppWindow, self).__init__(application=application)
		self.application = application
		self.logger = logging.getLogger('KingPhisher.Client.MainWindow')
		self.config = config
		"""The main King Phisher client configuration."""
		self.set_property('title', 'King Phisher')
		vbox = Gtk.Box()
		vbox.set_property('orientation', Gtk.Orientation.VERTICAL)
		vbox.show()
		self.add(vbox)

		default_icon_file = find.data_file('king-phisher-icon.svg')
		if default_icon_file:
			icon_pixbuf = GdkPixbuf.Pixbuf.new_from_file(default_icon_file)
			self.set_default_icon(icon_pixbuf)
		self.accel_group = Gtk.AccelGroup()
		self.add_accel_group(self.accel_group)

		self.menu_bar = MainMenuBar(application, self)
		vbox.pack_start(self.menu_bar.menubar, False, False, 0)

		# create notebook and tabs
		self.notebook = Gtk.Notebook()
		"""The primary :py:class:`Gtk.Notebook` that holds the top level taps of the client GUI."""
		self.notebook.connect('switch-page', self.signal_notebook_switch_page)
		self.notebook.set_scrollable(True)
		vbox.pack_start(self.notebook, True, True, 0)

		self.tabs = {}
		current_page = self.notebook.get_current_page()
		self.last_page_id = current_page

		mailer_tab = MailSenderTab(self, self.application)
		self.tabs['mailer'] = mailer_tab
		self.notebook.insert_page(mailer_tab.box, mailer_tab.label, current_page + 1)
		self.notebook.set_current_page(current_page + 1)

		campaign_tab = CampaignViewTab(self, self.application)
		campaign_tab.box.show()
		self.tabs['campaign'] = campaign_tab
		self.notebook.insert_page(campaign_tab.box, campaign_tab.label, current_page + 2)

		self.set_position(Gtk.WindowPosition.CENTER_ALWAYS)
		self.set_size_request(800, 600)
		self.connect('delete-event', self.signal_delete_event)
		self.notebook.show()

		self.show()
		self.rpc = None  # needs to be initialized last
		"""The :py:class:`.KingPhisherRPCClient` instance."""

		self.application.connect('server-connected', self.signal_kp_server_connected)

		self.login_dialog = dialogs.LoginDialog(self.application)
		self.login_dialog.dialog.connect('response', self.signal_login_dialog_response)
		self.login_dialog.dialog.show()

	def signal_notebook_switch_page(self, notebook, current_page, index):
		#previous_page = notebook.get_nth_page(self.last_page_id)
		self.last_page_id = index
		mailer_tab = self.tabs.get('mailer')
		campaign_tab = self.tabs.get('campaign')

		notebook = None
		if mailer_tab and current_page == mailer_tab.box:
			notebook = mailer_tab.notebook
		elif campaign_tab and current_page == campaign_tab.box:
			notebook = campaign_tab.notebook

		if notebook:
			index = notebook.get_current_page()
			notebook.emit('switch-page', notebook.get_nth_page(index), index)

	def signal_delete_event(self, x, y):
		self.application.emit('exit-confirm')
		return True

	def signal_kp_server_connected(self, _):
		self.rpc = self.application.rpc
		if self.login_dialog:
			self.login_dialog.destroy()
			self.login_dialog = None

	def signal_login_dialog_response(self, dialog, response):
		if response == Gtk.ResponseType.CANCEL or response == Gtk.ResponseType.DELETE_EVENT:
			dialog.destroy()
			self.application.emit('exit')
			return True
		self.login_dialog.objects_save_to_config()
		username = self.config['server_username']
		password = self.config['server_password']
		otp = self.config['server_one_time_password']
		if not otp:
			otp = None
		_, reason = self.application.server_connect(username, password, otp)
		if reason == ConnectionErrorReason.ERROR_INVALID_OTP:
			revealer = self.login_dialog.gobjects['revealer_server_one_time_password']
			if revealer.get_child_revealed():
				gui_utilities.show_dialog_error('Login Failed', self, 'A valid one time password (OTP) token is required.')
			else:
				revealer.set_reveal_child(True)
			entry = self.login_dialog.gobjects['entry_server_one_time_password']
			entry.grab_focus()
		elif reason == ConnectionErrorReason.ERROR_INVALID_CREDENTIALS:
			gui_utilities.show_dialog_error('Login Failed', self, 'The provided credentials are incorrect.')
		elif reason == ConnectionErrorReason.ERROR_UNKNOWN:
			gui_utilities.show_dialog_error('Login Failed', self, 'An unknown error has occurred.')

	def export_campaign_xlsx(self):
		"""Export the current campaign to an Excel compatible XLSX workbook."""
		dialog = extras.FileChooserDialog('Export Campaign To Excel', self)
		file_name = self.config['campaign_name'] + '.xlsx'
		response = dialog.run_quick_save(file_name)
		dialog.destroy()
		if not response:
			return
		destination_file = response['target_path']
		campaign_tab = self.tabs['campaign']
		workbook = xlsxwriter.Workbook(destination_file)
		title_format = workbook.add_format({'bold': True, 'size': 18})
		for tab_name, tab in campaign_tab.tabs.items():
			if not isinstance(tab, CampaignViewGenericTableTab):
				continue
			tab.export_table_to_xlsx_worksheet(workbook.add_worksheet(tab_name), title_format)
		workbook.close()

	def export_campaign_xml(self):
		"""Export the current campaign to an XML data file."""
		dialog = extras.FileChooserDialog('Export Campaign XML Data', self)
		file_name = self.config['campaign_name'] + '.xml'
		response = dialog.run_quick_save(file_name)
		dialog.destroy()
		if not response:
			return
		destination_file = response['target_path']
		export.campaign_to_xml(self.rpc, self.config['campaign_id'], destination_file)

	def export_message_data(self, *args, **kwargs):
		self.tabs['mailer'].export_message_data(*args, **kwargs)

	def export_campaign_visit_geojson(self):
		"""
		Export the current campaign visit information to a GeoJSON data file.
		"""
		dialog = extras.FileChooserDialog('Export Campaign Visit GeoJSON Data', self)
		file_name = self.config['campaign_name'] + '.geojson'
		response = dialog.run_quick_save(file_name)
		dialog.destroy()
		if not response:
			return
		destination_file = response['target_path']
		export.campaign_visits_to_geojson(self.rpc, self.config['campaign_id'], destination_file)

	def import_message_data(self, *args, **kwargs):
		self.tabs['mailer'].import_message_data(*args, **kwargs)
