%groupname = 'all'
%groupalias = 'All hosts'
%title = 'Minemap for all hosts'

%helper = app.helper
%datamgr = app.datamgr

%# Specific content for breadrumb
%rebase("layout", title='Minemap for hosts/services', refresh=True, css=['minemap/css/minemap.css'], breadcrumb=[ ['All hosts', '/minemap'], [groupalias, '/hosts-group/all'] ])


<div id="minemap">
   %if not hosts:
      <center>
         %if search_string:
         <h3>Bummer, we couldn't find anything.</h3>
         Use the filters or the bookmarks to find what you are looking for, or try a new search query.
         %else:
         <h3>No host or service.</h3>
         %end
      </center>
   %else:
      %#rows and columns will contain, respectively, all different hosts and all different services ...
      %rows = []
      %columns = []

      %for h in hosts:
         %if not h.get_name() in rows:
            %# Include host name even if it has no services ...
            %rows.append(h.get_name())
            
            %for s in h.services:
               %columns.append(s.get_name())
            %end
         %end
      %end
      %rows.sort()
      %import collections
      %columns = collections.Counter(columns)
      %columns = [c for c, i in columns.most_common()]

      %synthesis = helper.get_synthesis(hosts)
      %s = synthesis['services']
      %h = synthesis['hosts']
      <!--
      <div class="well well-sm">
         <table class="table table-invisible">
            <tbody>
               <tr>
                  <td>
                     <b>{{s['nb_elts']}} services:&nbsp;</b> 
                  </td>
             
                  %for state in 'ok', 'warning', 'critical', 'pending', 'unknown', 'ack', 'downtime':
                  <td>
                    %label = "%s <i>(%s%%)</i>" % (s['nb_' + state], s['pct_' + state])
                    {{!helper.get_fa_icon_state_and_label(cls='service', state=state, label=label, disabled=(not s['nb_' + state]))}}
                  </td>
                  %end
               </tr>
            </tbody>
         </table>
      </div>
      -->
      
      <div class="panel panel-default">
         <div class="panel-heading">
            <h3 class="panel-title">Current filtered hosts</h3>
         </div>
         <div class="panel-body">
            <div class="pull-left col-lg-2" style="height: 45px;">
               <span>Members:</span>
               <span>{{h['nb_elts']}} hosts</span>
            </div>
            <div class="pull-right progress col-lg-6 no-bottommargin no-leftpadding no-rightpadding" style="height: 45px;">
               <div title="{{h['nb_up']}} hosts Up" class="progress-bar progress-bar-success quickinfo" role="progressbar" 
                  data-original-title="{{h['nb_up']}} Up"
                  style="width: {{h['pct_up']}}%; vertical-align:midddle; line-height: 45px;">{{h['pct_up']}}% Up</div>
               <div title="{{h['nb_down']}} hosts Down" class="progress-bar progress-bar-danger quickinfo" 
                  data-original-title="{{h['pct_down']}} Down"
                  style="width: {{h['pct_down']}}%; vertical-align:midddle; line-height: 45px;">{{h['pct_down']}}% Down</div>
               <div title="{{h['nb_unreachable']}} hosts Unreachable" class="progress-bar progress-bar-warning quickinfo" 
                  data-original-title="{{h['nb_unreachable']}} Unreachable" 
                  style="width: {{h['pct_unreachable']}}%; vertical-align:midddle; line-height: 45px;">{{h['pct_unreachable']}}% Unreachable</div>
               <div title="{{h['nb_pending'] + h['nb_unknown']}} hosts Pending/Unknown" class="progress-bar progress-bar-info quickinfo" 
                  data-original-title="{{h['nb_pending'] + h['nb_unknown']}} Pending / Unknown"
                  style="width: {{h['pct_pending'] + h['pct_unknown']}}%; vertical-align:midddle; line-height: 45px;">{{h['pct_pending'] + h['pct_unknown']}}% Pending or Unknown</div>
            </div>
         </div>
      </div>

      <table class="table table-hover minemap">
         <thead>
            <tr>
               <th></th>
               %for c in columns:
                  <th class="vertical">
                  <div class="rotated-text"><span class="rotated-text__inner">{{c}}</span></div>
                  </th>
               %end
            </tr>
         </thead>
         <tbody>
            %for r in rows:
               %h = app.get_host(r)
               %if h:
               <tr>
                  <td>
                     <span title="{{h.state}} - {{helper.print_duration(h.last_chk)}} - {{h.output}}">
                     {{!helper.get_fa_icon_state(h)}}
                     </span>
                     <a href="/host/{{h.get_name()}}">
                        {{h.get_name()}}
                     </a>
                  </td>
                  %for c in columns:
                     %s = app.get_service(r, c)
                     %if s:
                        <td>
                           <a href="/service/{{h.get_name()}}/{{s.get_name()}}">
                              <span title="{{s.state}} - {{helper.print_duration(s.last_chk)}} - {{s.output}}">
                              {{!helper.get_fa_icon_state(s)}}
                              </span>
                           </a>
                        </td>
                     %else:
                        <td>&nbsp;</td>
                     %end
                  %end
               </tr>
               %end
            %end
         </tbody>
      </table>
   %end
</div>
