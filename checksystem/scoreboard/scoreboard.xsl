<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html"/>
  <xsl:decimal-format name="NaN2ZeroFormat" NaN="0"/>

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <style>@import "scoreboard.css";</style>
        <script type="text/javascript" src="scripts.js"></script>
        <script type="text/javascript" src="scoreboard.js"></script>
        <title>RuCTF 2010 - Скорборд</title>
        <meta http-equiv="Refresh" content="120"/>
      </head>
      <body onload="restoreState(); parse_emails();">
        <div id="mainWrapper">
          <div id="centeredImage">
          </div>
          <div id="in">
            <table id="inTable">
              <tr valign="top">
                <td id="inSpacer1">&#160;</td>
                <td id="inContent">
                  <div>
                    <a class="menulink" href="news.html">Новости</a>
                    <a class="selected" href="#">Скорборд</a>
                    <a class="menulink" href="flags.xml">Флаги</a>
                    <a class="menulink" href="/advisories/">Адвайзори</a>
                    <a class="menulink" href="visualizer.html">Визуализация</a>
                  </div>

                  <div style="text-align:right">
                    <h5>
                      Раунд #<xsl:value-of select="/scoreboard/@round"/> (начался в <xsl:value-of select="/scoreboard/@roundStartTimeUTC"/> UTC)
                    </h5>
                  </div>
                  
                  
                  <h1 id="centeredTitle">
                    Выбранные команды
                  </h1>
                  
                  <xsl:apply-templates select="scoreboard">
                    <xsl:with-param name="class">inSelectedScoreboard</xsl:with-param>
                  </xsl:apply-templates>

                  <h1 id="centeredTitle">
                    Все команды
                  </h1>
                  <xsl:apply-templates select="scoreboard">
                    <xsl:with-param name="class">inFullScoreboard</xsl:with-param>
                  </xsl:apply-templates>
                  <div style="text-align:center">
                    <h5>
                      Cгенерировано <xsl:value-of select="/scoreboard/@genTimeUTC"/> UTC
                    </h5>
                  </div>
                </td>
                <td id="inSpacer3">&#160;</td>
              </tr>
            </table>
          </div>
          <div id="footWrap"></div>
        </div>

        <div id="footer">
          <div id="footer2">
            <div id="contacts">
              По всем вопросам можно обращаться по адресу <a href="mailto:info[at]ructf.org">
                <span class="email">info[at]ructf.org</span>
              </a>
              <xsl:element name="br"/>
              Официальная рассылка соревнований: <a href="http://groups.google.com/group/ructf/">http://groups.google.com/group/ructf/</a><xsl:element name="br"/>
              IRC-канал: #ructf2010@<a href="http://ru.wikipedia.org/wiki/IrcNet.ru">IrcNet.ru</a>
            </div>
            <div id="copyright">&#xA9; 2010 HackerDom</div>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="scoreboard">
    <xsl:param name="class"/>
    <table width="855" class="scoreboard" cellspacing="0" cellpadding="10">
      
      <col width="10" /><!-- место -->
      <col width="50" /><!-- лого команды -->
      <col width="100" /><!-- имя команды -->
      
      
      <col width="50" /><!-- Рейтинг -->
      <col width="50" /><!-- Защита -->
      <col width="50" /><!-- Атака -->
      <col width="50" /><!-- Адвайзори -->
      <col width="50" /> <!-- Таски -->
      
      <col width="50" />
      <col width="50" />
      <col width="50" />
      <col width="50" />
      <col width="50" />
      <col width="50" />
      <col width="50" />
      

      <tr>
        <th>#</th>
        <th>Лого  </th>
        <th>Команда</th>
        <th>Рейтинг</th>
        <th>Защита</th>
        <th>Атака</th>
        <th>Адвайзори</th>
        <th>Таски</th>
        <xsl:for-each select="team[1]/services/service">
          <th>
            <xsl:value-of select="@name"/>
          </th>
        </xsl:for-each>
        <th>
          #
        </th>
      </tr>


      <xsl:variable name="maxDefence">
        <xsl:for-each select="team/scores/@defence">
          <xsl:sort data-type="number" order="descending"/>
          <xsl:if test="position()=1">
            <xsl:value-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="maxAttack">
        <xsl:for-each select="team/scores/@attack">
          <xsl:sort data-type="number" order="descending"/>
          <xsl:if test="position()=1">
            <xsl:value-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="maxAdvisories">
        <xsl:for-each select="team/scores/@advisories">
          <xsl:sort data-type="number" order="descending"/>
          <xsl:if test="position()=1">
            <xsl:value-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      
      <xsl:variable name="maxTasks">
        <xsl:for-each select="team/scores/@tasks">
          <xsl:sort data-type="number" order="descending"/>
          <xsl:if test="position()=1">
            <xsl:value-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
            

      <xsl:variable name="maxTotalPercent">
        <xsl:for-each select="team">
          <xsl:sort select="format-number(scores/@defence div $maxDefence, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@attack div $maxAttack, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@advisories div $maxAdvisories, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@tasks div $maxTasks, '0.######', 'NaN2ZeroFormat')"
                          data-type="number"
                          order="descending"/>
          <xsl:if test="position()=1">
            <xsl:value-of select="number(format-number(scores/@defence div $maxDefence, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@attack div $maxAttack, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@tasks div $maxTasks, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@advisories div $maxAdvisories, '0.######', 'NaN2ZeroFormat'))"/>
          </xsl:if>
        </xsl:for-each>        
      </xsl:variable>
      

      <xsl:for-each select="team">
        <xsl:sort select="format-number(scores/@defence div $maxDefence, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@attack div $maxAttack, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@tasks div $maxTasks, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@advisories div $maxAdvisories, '0.######', 'NaN2ZeroFormat')"
                          data-type="number"
                          order="descending"/>
        <xsl:sort select="@name" data-type="text" order="ascending"/>

        <xsl:variable name="totalPersent"
                      select="number(format-number(scores/@defence div $maxDefence, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@attack div $maxAttack, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@tasks div $maxTasks, '0.######', 'NaN2ZeroFormat') +
                          format-number(scores/@advisories div $maxAdvisories, '0.######', 'NaN2ZeroFormat'))"/>

        <tr id="{$class}_{@vulnBox}" class="{$class}">
          <!-- Место -->
          <td>
            <xsl:value-of select="position()"/>
          </td>
          
          <!-- Лого -->
          <td>
            <xsl:element name="img">
              <xsl:attribute name="src">img/<xsl:value-of select="@name"/></xsl:attribute>
              <xsl:attribute name="alt"><xsl:value-of select="@name"/></xsl:attribute>
			        <xsl:attribute name="width">50</xsl:attribute>
			        <xsl:attribute name="height">50</xsl:attribute>
            </xsl:element>
          </td>
          
          <td>
            <a href="#" class="info">
              <xsl:value-of select="@name"/>
              <span class="tooltip">
                <span class="top">
                </span>
                <span class="middle">
                  <xsl:value-of select="@vulnBox"/>
                </span>
                <span class="bottom">
                </span>
              </span>
            </a>
          </td>
          
          <!-- Очки команд -->

          <xsl:variable name="viewCoef">1</xsl:variable>
          
          <td ><!-- общее -->
            <xsl:variable name="viewTotalPercent">
              <xsl:value-of select="format-number(100 * $totalPersent div $maxTotalPercent, '0.##', 'NaN2ZeroFormat')"/>
            </xsl:variable>
            <xsl:variable name="colorTotalIntensivity">
              <xsl:value-of select="format-number((100 - $viewTotalPercent) * $viewCoef, '0.##', 'NaN2ZeroFormat')"/>
            </xsl:variable>
            <xsl:attribute name="style">background-color:rgb(100%,<xsl:value-of select="50 + $colorTotalIntensivity"/>%,<xsl:value-of select="$colorTotalIntensivity"/>%)</xsl:attribute>

            <xsl:value-of select="$viewTotalPercent"/><![CDATA[%]]>
          </td>
          <td>
            <xsl:variable name="viewDefencePercent">
              <xsl:value-of select="format-number(100 * scores/@defence div $maxDefence, '0.##', 'NaN2ZeroFormat')"/>
            </xsl:variable>
            <xsl:variable name="colorDefenceIntensivity">
              <xsl:value-of select="format-number((100 - $viewDefencePercent) * $viewCoef, '0.##', 'NaN2ZeroFormat')"/>
            </xsl:variable>
            <xsl:attribute name="style">
              background-color:rgb(100%,<xsl:value-of select="50 + $colorDefenceIntensivity"/>%,<xsl:value-of select="$colorDefenceIntensivity"/>%)
            </xsl:attribute>

            <xsl:value-of select="$viewDefencePercent"/><![CDATA[%]]><br/>
            (<xsl:value-of select="format-number(scores/@defence, '0', 'NaN2ZeroFormat')"/>)
          </td>
          <td>
            <xsl:variable name="viewAttackPercent">
              <xsl:value-of select="format-number(100 * scores/@attack div $maxAttack, '0.##', 'NaN2ZeroFormat')"/>
            </xsl:variable>
            <xsl:variable name="colorAttackIntensivity">
              <xsl:value-of select="format-number((100 - $viewAttackPercent) * $viewCoef, '0.##', 'NaN2ZeroFormat')"/>
            </xsl:variable>
            <xsl:attribute name="style">
              background-color:rgb(100%,<xsl:value-of select="50 + $colorAttackIntensivity"/>%,<xsl:value-of select="$colorAttackIntensivity"/>%)
            </xsl:attribute>

            <xsl:value-of select="$viewAttackPercent"/><![CDATA[%]]><br/>
            (<xsl:value-of select="format-number(scores/@attack, '0', 'NaN2ZeroFormat')"/>)            
          </td>
          <td>
            <xsl:variable name="viewAdvisoriesPercent">
              <xsl:value-of select="format-number(100 * scores/@advisories div $maxAdvisories, '0.##', 'NaN2ZeroFormat')"/>
            </xsl:variable>
            <xsl:variable name="colorAdvisoriesIntensivity">
              <xsl:value-of select="format-number((100 - $viewAdvisoriesPercent) * $viewCoef, '0.##', 'NaN2ZeroFormat')"/>
            </xsl:variable>
            <xsl:attribute name="style">
              background-color:rgb(100%,<xsl:value-of select="50 + $colorAdvisoriesIntensivity"/>%,<xsl:value-of select="$colorAdvisoriesIntensivity"/>%)
            </xsl:attribute>


            <xsl:value-of select="$viewAdvisoriesPercent"/><![CDATA[%]]><br/>
            (<xsl:value-of select="format-number(scores/@advisories, '0', 'NaN2ZeroFormat')"/>)
            
          </td>
          <td>
            <xsl:variable name="viewTasksPercent">
              <xsl:value-of select="format-number(100 * scores/@tasks div $maxTasks, '0.##', 'NaN2ZeroFormat')"/>
            </xsl:variable>
            <xsl:variable name="colorTasksIntensivity">
              <xsl:value-of select="format-number((100 - $viewTasksPercent) * $viewCoef, '0.##', 'NaN2ZeroFormat')"/>
            </xsl:variable>
            <xsl:attribute name="style">
              background-color:rgb(100%,<xsl:value-of select="50 + $colorTasksIntensivity"/>%,<xsl:value-of select="$colorTasksIntensivity"/>%)
            </xsl:attribute>

            <xsl:value-of select="$viewTasksPercent"/><![CDATA[%]]><br/>
            (<xsl:value-of select="format-number(scores/@tasks, '0', 'NaN2ZeroFormat')"/>)
          </td>
          
          <xsl:for-each select="services/service">
            <xsl:element name="td">
              <xsl:attribute name="class">
                <xsl:choose>
                  <xsl:when test="@status = 101">
                    serviceUp
                  </xsl:when>
                  <xsl:when test="@status = 102">
                    serviceCorrupt
                  </xsl:when>
                  <xsl:when test="@status = 103">
                    serviceMumble
                  </xsl:when>
                  <xsl:when test="@status = 104">
                    serviceDown
                  </xsl:when>
                  <xsl:otherwise>
                    serviceCheckerError
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              

              <a href="#" class="info">
                <xsl:choose>
                  <xsl:when test="@status = 101">
                    up
                  </xsl:when>
                  <xsl:when test="@status = 102">
                    corrupt
                  </xsl:when>
                  <xsl:when test="@status = 103">
                    mumble
                  </xsl:when>
                  <xsl:when test="@status = 104">
                    down
                  </xsl:when>
                  <xsl:otherwise>
                    checker error
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="@fail_comment != ''">                
                  <span class="tooltip">
                    <span class="top">
                    </span>
                    <span class="middle">
                      <xsl:value-of select="@fail_comment"/>
                    </span>
                    <span class="bottom">
                    </span>
                  </span>
                </xsl:if>
              </a>              
            </xsl:element>

          </xsl:for-each>
          <td>
            <input type="checkbox" id="{$class}_chk{@vulnBox}" onclick="checkBox_OnClick('{@vulnBox}', this)"/>
          </td>
        </tr>
      </xsl:for-each>
      <tr>
        <th>#</th>
        <th>Лого  </th>
        <th>Команда</th>
        <th>Общее</th>
        <th>Защита</th>
        <th>Атака</th>
        <th>Адвайзори</th>
        <th>Таски</th>
        <xsl:for-each select="team[1]/services/service">
          <th>
            <xsl:value-of select="@name"/>
          </th>
        </xsl:for-each>
        
          <th>
            #
          </th>
        
      </tr>
      
    </table>    
  </xsl:template>

</xsl:stylesheet>
