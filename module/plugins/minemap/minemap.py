#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright (C) 2009-2012:
#    Gabes Jean, naparuba@gmail.com
#    Mohier Frederic frederic.mohier@gmail.com
#    Karfusehr Andreas, frescha@unitedseed.de
# This file is part of Shinken.
#
# Shinken is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Shinken is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Shinken.  If not, see <http://www.gnu.org/licenses/>.

### Will be populated by the UI with it's own value
app = None

from shinken.log import logger
from shinken.misc.sorter import hst_srv_sort
from shinken.misc.filter import only_related_to

# Get plugin's parameters from configuration file
# params = {}
# params['elts_per_page'] = 10

# def load_cfg():
    # global params
    
    # import os,sys
    # from webui.config_parser import config_parser
    # plugin_name = os.path.splitext(os.path.basename(__file__))[0]
    # try:
        # currentdir = os.path.dirname(os.path.realpath(__file__))
        # configuration_file = "%s/%s" % (currentdir, 'plugin.cfg')
        # logger.debug("Plugin configuration file: %s" % (configuration_file))
        # scp = config_parser('#', '=')
        # params = scp.parse_config(configuration_file)

        # params['elts_per_page'] = int(params['elts_per_page'])
        
        # params['minemap_hostsLevel'] = [int(item) for item in params['minemap_hostsLevel'].split(',')]
        # params['minemap_hostsShow'] = [item for item in params['minemap_hostsShow'].split(',')]
        # params['minemap_hostsHide'] = [item for item in params['minemap_hostsHide'].split(',')]
        # params['minemap_servicesLevel'] = [int(item) for item in params['minemap_servicesLevel'].split(',')]
        # params['minemap_servicesHide'] = [item for item in params['minemap_servicesHide'].split(',')]
        
        # logger.info("[webui-minemap] configuration loaded.")
        # logger.debug("[webui-minemap] configuration, elts_per_page: %d", params['elts_per_page'])
        # logger.debug("[webui-minemap] configuration, minemap hosts level: %s", params['minemap_hostsLevel'])
        # logger.debug("[webui-minemap] configuration, minemap hosts always shown: %s", params['minemap_hostsShow'])
        # logger.debug("[webui-minemap] configuration, minemap hosts always hidden: %s", params['minemap_hostsHide'])
        # logger.debug("[webui-minemap] configuration, minemap services level: %s", params['minemap_servicesLevel'])
        # logger.debug("[webui-minemap] configuration, minemap services hide: %s", params['minemap_servicesHide'])
        # return True
    # except Exception, exp:
        # logger.warning("[webui-minemap] configuration file (%s) not available: %s", configuration_file, str(exp))
        # return False

# def reload_cfg():
    # load_cfg()
    # app.bottle.redirect("/config")

def show_minemap():
    user = app.check_user_authentication()

    # Apply search filter for minemap hosts ...
    search = ' '.join(app.request.GET.getall('search')) or ""
    hosts = app.search_hosts_and_services(search, user, get_impacts=False, hosts_only=True)
    
    # Fetch elements per page preference for user, default is 25
    elts_per_page = app.get_user_preference(user, 'elts_per_page', 25)

    # We want to limit the number of elements
    step = int(app.request.GET.get('step', elts_per_page))
    start = int(app.request.GET.get('start', '0'))
    end = int(app.request.GET.get('end', start + step))
        
    # If we overflow, came back as normal
    total = len(hosts)
    if start > total:
        start = 0
        end = step

    navi = app.helper.get_navi(total, start, step=step)

    return {'app': app, 'user': user, 'navi': navi, 'search_string': search, 'hosts': hosts[start:end], 'page': "minemap"}

def show_minemaps():
    user = app.check_user_authentication()

    app.bottle.redirect("/minemap/all")


# Load plugin configuration parameters
# load_cfg()

pages = {
    # reload_cfg: {'routes': ['/reload/minemap']},

    show_minemap: {'routes': ['/minemap'], 'view': 'minemap', 'static': True},
    show_minemaps: {'routes': ['/minemaps'], 'view': 'minemap', 'static': True}
}
