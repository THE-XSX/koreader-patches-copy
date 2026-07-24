local Blitbuffer = require("ffi/blitbuffer")
local CenterContainer = require("ui/widget/container/centercontainer")
local Device = require("device")
local Dispatcher = require("dispatcher")
local Font = require("ui/font")
local FrameContainer = require("ui/widget/container/framecontainer")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local DataStorage = require("datastorage")
local DocumentRegistry = require("document/documentregistry")
local ImageWidget = require("ui/widget/imagewidget")
local InputContainer = require("ui/widget/container/inputcontainer")
local InputDialog = require("ui/widget/inputdialog")													
local ProgressWidget = require("ui/widget/progresswidget")
local ReaderUI = require("apps/reader/readerui")
local RenderImage = require("ui/renderimage")
local OverlapGroup = require("ui/widget/overlapgroup")
local ScreenSaverWidget = require("ui/widget/screensaverwidget")
local TextWidget = require("ui/widget/textwidget")
local TextBoxWidget = require("ui/widget/textboxwidget")
local UIManager = require("ui/uimanager")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local lfs = require("libs/libkoreader-lfs")
local bit = require("bit")
local datetime = require("datetime")
local logger = require("logger")
local util = require("util")
local ffiUtil = require("ffi/util")
local SQ3 = require("lua-ljsqlite3/init")
local _ = require("gettext")

do
    local zh_translations = {
        ["%1 et al."] = "%1 等",
        ["Page %s"] = "第%s页",
        ["Receipt unavailable"] = "无法显示阅读摘要",
        ["Book receipt"] = "阅读摘要",
        ["Show book receipt on sleep screen"] = "在休眠屏幕显示阅读摘要",
        ["Background"] = "背景",
        ["White fill"] = "白色背景",
        ["Transparent"] = "透明",
        ["Black fill"] = "黑色背景",
        ["Random image"] = "随机图片",
        ["Book cover"] = "书籍封面",
        ["Background image placement"] = "背景图片显示方式",
        ["Fit to screen"] = "适应屏幕",
        ["Stretch to screen"] = "拉伸填满屏幕",
        ["Center without scaling"] = "居中（不缩放）",
        ["Content"] = "内容",
        ["Book receipt (default)"] = "阅读摘要（默认）",
        ["Highlight + progress"] = "高亮与进度",
        ["Random"] = "随机",
        ["Cover scale"] = "封面缩放",
        ["Cover scale (default: 1.0)\nSet to 0 to hide cover"] = "封面缩放（默认：1.0）\n设置为0以隐藏封面",
        ["Cancel"] = "取消",
        ["Set"] = "确定",
        ["Book receipt settings"] = "阅读摘要设置",
        ["Style"] = "显示风格",
        ["Swiss grid"] = "瑞士网格",
        ["Terminal"] = "黑底终端",
        ["Editorial"] = "极简书刊",
        ["Receipt"] = "真实小票",
        ["Dashboard"] = "数据仪表盘",
        ["Quote poster"] = "引文海报",
        ["Ticket stub"] = "阅读票根",
        ["Cover first"] = "封面主导",
        ["Japanese minimal"] = "日式留白",
        ["BOOK RECEIPT"] = "阅读摘要",
        ["READING PROGRESS"] = "阅读进度",
        ["NOW READING"] = "当前阅读",
        ["calculating time"] = "计算中",
        ["hr"] = "小时",
        ["hrs"] = "小时",
        ["min"] = "分钟",
        ["mins"] = "分钟",
        ["less than a minute"] = "不足一分钟",
        ["Total time spent: %s"] = "累计阅读时间：%s",
        ["Time spent today (%s): %s"] = "今日阅读时间（%s）：%s",
        ["page %s of %s"] = "第%s页 / 共%s页",
        ["Book"] = "书籍",
        ["Chapter"] = "章节",
        ["%s left in %s"] = "%s 剩余 %s",
        ["Monday"] = "周一",
        ["Tuesday"] = "周二",
        ["Wednesday"] = "周三",
        ["Thursday"] = "周四",
        ["Friday"] = "周五",
        ["Saturday"] = "周六",
        ["Sunday"] = "周日",
        ["Show cover"] = "显示封面",
        ["Display items"] = "展示信息条目",
        ["Book title"] = "书名",
        ["Author"] = "作者",
        ["Cover"] = "封面",
        ["Current chapter"] = "当前章节",
        ["Page count"] = "当前页 / 总页数",
        ["Reading percentage"] = "阅读百分比",
        ["Progress bar"] = "进度条",
        ["Chapter time left"] = "本章剩余时间",
        ["Book time left"] = "全书剩余时间",
        ["Total time spent"] = "累计阅读时间",
        ["Time spent today"] = "今日阅读时间",
        ["Battery level"] = "电量",
        ["Current time"] = "当前时间",
        ["Highlights & annotations"] = "高亮摘录及其章节/页码",
        ["Custom screensaver message"] = "自定义屏保消息",
        ["Card width mode"] = "卡片尺寸比例",
        ["Default ratio"] = "默认比例",
        ["Fullscreen"] = "全屏",
        ["Custom ratio"] = "手动设置比例",
        ["Custom card ratio (0.30 - 1.00)\ne.g. 0.65 for 65% screen width"] = "自定义卡片宽度比例 (0.30 - 1.00)\n例如：输入 0.65 或 65 代表 65% 屏幕宽度",
        ["Card appearance"] = "卡片外观装饰",
        ["Card border"] = "卡片外边框",
        ["No border"] = "无边框 (默认)",
        ["Thin border"] = "细线边框",
        ["Thick border"] = "粗线边框",
        ["Card background color"] = "框内背景颜色",
        ["Light gray (default)"] = "淡灰色 (推荐/悬浮)",
        ["Pure white"] = "纯白色",
        ["Soft gray"] = "浅灰色",
        ["Card drop shadow"] = "卡片立体阴影",
        ["Enable drop shadow"] = "开启投射阴影",
    }
    local orig__ = _
    _ = function(s)
        if type(s) == "string" and zh_translations[s] then return zh_translations[s] end
        return orig__(s)
    end
    _G._ = _
end

local Screen = Device.screen 
local T = ffiUtil.template
local K = {
    BG_SETTING = "book_receipt_screensaver_background",
    BG_IMAGE_MODE_SETTING = "book_receipt_bg_image_mode",
    CONTENT_MODE_SETTING = "book_receipt_content_mode",
    COVER_SCALE_SETTING = "book_receipt_cover_scale",
    SHOW_COVER_SETTING = "book_receipt_show_cover",
    STYLE_SETTING = "book_receipt_style",
    CARD_RATIO_MODE = "book_receipt_card_ratio_mode",
    CARD_RATIO_CUSTOM = "book_receipt_card_ratio_custom",
    BORDER = "book_receipt_card_border",
    CARD_BG = "book_receipt_card_bg",
    SHADOW = "book_receipt_card_shadow",

    SHOW_TITLE = "book_receipt_show_title",
    SHOW_AUTHOR = "book_receipt_show_author",
    SHOW_COVER = "book_receipt_show_cover",
    SHOW_CHAPTER = "book_receipt_show_chapter",
    SHOW_PAGE_NUMBER = "book_receipt_show_page_number",
    SHOW_PERCENTAGE = "book_receipt_show_percentage",
    SHOW_PROGRESS_BAR = "book_receipt_show_progress_bar",
    SHOW_CHAPTER_TIME_LEFT = "book_receipt_show_chapter_time_left",
    SHOW_BOOK_TIME_LEFT = "book_receipt_show_book_time_left",
    SHOW_TOTAL_TIME = "book_receipt_show_total_time",
    SHOW_TODAY_TIME = "book_receipt_show_today_time",
    SHOW_BATTERY = "book_receipt_show_battery",
    SHOW_CLOCK = "book_receipt_show_clock",
    SHOW_HIGHLIGHTS = "book_receipt_show_highlights",
    SHOW_CUSTOM_MESSAGE = "book_receipt_show_custom_message",

    MAX_HIGHLIGHT_SIZE = 500,
    HIDE_COVER_FOR_LARGE_HIGHLIGHTS = 300,

    CONTENT_MODE_BOOK_RECEIPT = "book_receipt",
    CONTENT_MODE_HIGHLIGHT_PROGRESS = "highlight_progress",
    CONTENT_MODE_RANDOM = "random",

    STYLE_SWISS = "swiss",
    STYLE_TERMINAL = "terminal",
    STYLE_QUOTE = "quote",
    STYLE_TICKET = "ticket",
    STYLE_COVER = "cover",
    STYLE_ZEN = "zen",
}

local function normalizeReceiptStyle(value)
    if value == "editorial" or value == "dashboard" then
        return K.STYLE_SWISS
    elseif value == "receipt" then
        return K.STYLE_TICKET
    elseif value == K.STYLE_SWISS or value == K.STYLE_TERMINAL or value == K.STYLE_QUOTE
            or value == K.STYLE_TICKET or value == K.STYLE_COVER or value == K.STYLE_ZEN then
        return value
    end
    return K.STYLE_SWISS
end

local function utf8TrimToLength(str, max_chars)
    if not str or max_chars <= 0 then
        return "", 0, str ~= nil and str ~= ""
    end
    local len = #str
    local index = 1
    local char_count = 0
    local cut_index
    while index <= len do
        local byte = string.byte(str, index)
        if not byte then break end
        local char_len = 1
        if byte >= 0xF0 then
            char_len = 4
        elseif byte >= 0xE0 then
            char_len = 3
        elseif byte >= 0xC0 then
            char_len = 2
        end
        char_count = char_count + 1
        index = index + char_len
        if not cut_index and char_count == max_chars + 1 then
            cut_index = index - char_len
        end
    end
    if cut_index then
        return str:sub(1, cut_index - 1), char_count, true
    end
    return str, char_count, false
end

local function getLocalizedDayName(timestamp)
    local day_key = timestamp and os.date("%A", timestamp)
    if not day_key then
        return ""
    end
    if datetime and datetime.longDayTranslation and datetime.longDayTranslation[day_key] then
        return datetime.longDayTranslation[day_key]
    end
    return _(day_key)
end

local function getBookTodayDuration(statistics)
    if not statistics then
        return nil
    end

    if statistics.isEnabled and not statistics:isEnabled() then
        return nil
    end

    if statistics.insertDB then
        pcall(statistics.insertDB, statistics)
    end

    local id_book = statistics.id_curr_book
    if (not id_book) and statistics.getIdBookDB then
        local ok, book_id = pcall(statistics.getIdBookDB, statistics)
        if ok then
            id_book = book_id
        end
    end
    if not id_book then
        return nil
    end

    if not STATISTICS_DB_PATH or STATISTICS_DB_PATH == "" then
        return nil
    end

    local attrs = lfs.attributes(STATISTICS_DB_PATH, "mode")
    if attrs ~= "file" then
        return nil
    end

    local now_stamp = os.time()
    local now_t = os.date("*t", now_stamp)
    local from_begin_day = now_t.hour * 3600 + now_t.min * 60 + now_t.sec
    local start_today_time = now_stamp - from_begin_day

    local ok_conn, conn = pcall(SQ3.open, STATISTICS_DB_PATH)
    if not ok_conn or not conn then
        return nil
    end

    local sql_stmt = string.format([[SELECT sum(sum_duration)
        FROM (
            SELECT sum(duration) AS sum_duration
            FROM page_stat
            WHERE start_time >= %d AND id_book = %d
            GROUP BY page
        );
    ]], start_today_time, id_book)

    local ok_row, today_duration = pcall(function()
        return conn:rowexec(sql_stmt)
    end)
    conn:close()

    if not ok_row or today_duration == nil then
        return nil
    end

    today_duration = tonumber(today_duration)
    if not today_duration then
        return nil
    end

    if today_duration < 0 then
        today_duration = 0
    end
    return today_duration
end

local function getRandomHighlightAnnotation(ui)
    if not ui or not ui.annotation or not ui.annotation.annotations then
        return nil
    end
    local candidates = {}
    for _, item in ipairs(ui.annotation.annotations) do
        if item.drawer and item.text then
            local trimmed = util.trim(item.text)
            if trimmed ~= "" then
                table.insert(candidates, item)
            end
        end
    end
    if #candidates == 0 then
        return nil
    end
    return candidates[math.random(#candidates)]
end

local function getBookReceiptBackgroundDir()
    local base_dir = DataStorage:getDataDir()
    if not base_dir or base_dir == "" then
        return nil
    end
    return string.format("%s/%s", base_dir, "book_receipt_background")
end

local function pickRandomReceiptBackgroundImage()
    local dir = getBookReceiptBackgroundDir()
    if not dir or lfs.attributes(dir, "mode") ~= "directory" then
        return nil
    end

    local files = {}
    util.findFiles(dir, function(file)
        if not util.stringStartsWith(ffiUtil.basename(file), "._") and DocumentRegistry:isImageFile(file) then
            table.insert(files, file)
        end
    end, false, 512)

    if #files == 0 then
        return nil
    end
    return files[math.random(#files)]
end

local function buildBackgroundImageWidget(image_source)
    if not image_source then
        return nil
    end

    local BOOK_RECEIPT_BG_IMAGE_MODE_SETTING = K.BG_IMAGE_MODE_SETTING
    local mode = G_reader_settings:readSetting(BOOK_RECEIPT_BG_IMAGE_MODE_SETTING) or "stretch"
    if mode ~= "center" and mode ~= "stretch" and mode ~= "fit" then
        mode = "stretch"
    end

    local screen_size = Screen:getSize()
    local screen_w, screen_h = screen_size.w, screen_size.h
    local image_opts = {
        alpha = true,
        file_do_cache = false,
    }

    if type(image_source) == "string" then
        image_opts.file = image_source
    else
        image_opts.image = image_source
    end

    if mode == "stretch" then
        image_opts.width = screen_w
        image_opts.height = screen_h
    elseif mode == "fit" then
        image_opts.width = screen_w
        image_opts.height = screen_h
        image_opts.scale_factor = 0
    end

    local image_widget = ImageWidget:new(image_opts)

    if mode == "center" then
        return CenterContainer:new{
            dimen = screen_size,
            image_widget,
        }
    end

    return image_widget
end

local function getActiveDocumentCover(ui)
    if not ui or not ui.document or not ui.bookinfo then
        return nil
    end
    return ui.bookinfo:getCoverImage(ui.document)
end

local function getReceiptBackground(ui)
    local BOOK_RECEIPT_BG_SETTING = K.BG_SETTING
    local choice = G_reader_settings:readSetting(BOOK_RECEIPT_BG_SETTING) or "white"

    if choice == "transparent" then
        return nil, nil
    elseif choice == "black" then
        return Blitbuffer.COLOR_BLACK, nil
    elseif choice == "random_image" then
        local image_path = pickRandomReceiptBackgroundImage()
        if image_path then
            local widget = buildBackgroundImageWidget(image_path)
            if widget then
                return nil, widget
            end
        end
        return nil, nil
    elseif choice == "book_cover" then
        local cover_bb = getActiveDocumentCover(ui)
        if cover_bb then
            local widget = buildBackgroundImageWidget(cover_bb)
            if widget then
                return nil, widget
            end
        end
        return nil, nil
    end

    return Blitbuffer.COLOR_WHITE, nil
end

-- QuickLook is an InputContainer rather than a ScreenSaverWidget, so its
-- background property is not enough to hide the reader/settings UI beneath it.
-- Paint an explicit full-screen layer for solid backgrounds and keep image
-- backgrounds in the same stacking order as the screensaver.
local function composeQuickLookReceipt(ui, receipt_widget)
    if not receipt_widget then
        return nil
    end

    local BOOK_RECEIPT_STYLE_SETTING = K.STYLE_SETTING
    local STYLE_TERMINAL = K.STYLE_TERMINAL

    local background_color, background_widget = getReceiptBackground(ui)
    local style = normalizeReceiptStyle(G_reader_settings:readSetting(BOOK_RECEIPT_STYLE_SETTING))
    if style == STYLE_TERMINAL and not background_widget then
        background_color = Blitbuffer.COLOR_BLACK
    end

    if not background_widget and not background_color then
        -- Transparent is intentional: leave the existing QuickLook behavior
        -- unchanged when the user explicitly asks for no background.
        return receipt_widget
    end

    local screen_size = Screen:getSize()
    if not background_widget then
        background_widget = ProgressWidget:new{
            width = screen_size.w,
            height = screen_size.h,
            percentage = 1,
            margin_v = 0,
            margin_h = 0,
            radius = 0,
            bordersize = 0,
            bgcolor = background_color,
            fillcolor = background_color,
        }
    end

    return OverlapGroup:new{
        dimen = screen_size,
        background_widget,
        receipt_widget,
    }
end

local function hasActiveDocument(ui)
    return ui and ui.document ~= nil
end

local function getBookReceiptFallbackType()
    local random_dir = G_reader_settings:readSetting("screensaver_dir")
    if random_dir and lfs.attributes(random_dir, "mode") == "directory" then
        return "random_image"
    end

    local document_cover = G_reader_settings:readSetting("screensaver_document_cover")
    if document_cover and lfs.attributes(document_cover, "mode") == "file" then
        return "document_cover"
    end

    local lastfile = G_reader_settings:readSetting("lastfile")
    if lastfile and lfs.attributes(lastfile, "mode") == "file" then
        return "cover"
    end

    return "random_image"
end

local function getEventFromPrefix(prefix)
    if prefix and prefix ~= "" then
        return prefix:sub(1, -2)
    end
    return nil
end

local function showFallbackScreensaver(self, orig_show)
    local fallback_type = getBookReceiptFallbackType()

    local original_type = self.screensaver_type
    local event = getEventFromPrefix(self.prefix)

    local settings = G_reader_settings
    local primary_key = "screensaver_type"
    local had_primary = settings:has(primary_key)
    local original_primary = settings:readSetting(primary_key)
    settings:saveSetting(primary_key, fallback_type)

    local prefixed_key = self.prefix and self.prefix ~= "" and (self.prefix .. "screensaver_type") or nil
    local had_prefixed, original_prefixed
    if prefixed_key then
        had_prefixed = settings:has(prefixed_key)
        original_prefixed = settings:readSetting(prefixed_key)
        settings:saveSetting(prefixed_key, fallback_type)
    end

    self:setup(event, self.event_message)
    self.screensaver_type = fallback_type
    orig_show(self)

    if prefixed_key then
        if had_prefixed then
            settings:saveSetting(prefixed_key, original_prefixed)
        else
            settings:delSetting(prefixed_key)
        end
    end

    if had_primary then
        settings:saveSetting(primary_key, original_primary)
    else
        settings:delSetting(primary_key)
    end

    self.screensaver_type = original_type
end

local function generateSimulatedBarcode(target_width, scaled_fn)
    local bar_patterns = { "█", "▌", "│", "║", "█", "▌", " ", "█", "║", "│", "█", "▌", "█" }
    local count = math.min(12, math.max(6, math.floor(target_width / math.max(scaled_fn(36), 24))))
    local bars = {}
    for i = 1, count do
        table.insert(bars, bar_patterns[(i % #bar_patterns) + 1])
    end
    return table.concat(bars)
end

local function buildReceipt(ui, state)
    if not hasActiveDocument(ui) then return nil end

    local BOOK_RECEIPT_BG_SETTING = K.BG_SETTING
    local BOOK_RECEIPT_BG_IMAGE_MODE_SETTING = K.BG_IMAGE_MODE_SETTING
    local BOOK_RECEIPT_CONTENT_MODE_SETTING = K.CONTENT_MODE_SETTING
    local BOOK_RECEIPT_COVER_SCALE_SETTING = K.COVER_SCALE_SETTING
    local BOOK_RECEIPT_SHOW_COVER_SETTING = K.SHOW_COVER_SETTING
    local BOOK_RECEIPT_STYLE_SETTING = K.STYLE_SETTING
    local CARD_RATIO_MODE_SETTING = K.CARD_RATIO_MODE
    local CARD_RATIO_CUSTOM_SETTING = K.CARD_RATIO_CUSTOM
    local BOOK_RECEIPT_BORDER_SETTING = K.BORDER
    local BOOK_RECEIPT_CARD_BG_SETTING = K.CARD_BG
    local BOOK_RECEIPT_SHADOW_SETTING = K.SHADOW

    local SHOW_ITEM_TITLE_SETTING = K.SHOW_TITLE
    local SHOW_ITEM_AUTHOR_SETTING = K.SHOW_AUTHOR
    local SHOW_ITEM_COVER_SETTING = K.SHOW_COVER
    local SHOW_ITEM_CHAPTER_SETTING = K.SHOW_CHAPTER
    local SHOW_ITEM_PAGE_NUMBER_SETTING = K.SHOW_PAGE_NUMBER
    local SHOW_ITEM_PERCENTAGE_SETTING = K.SHOW_PERCENTAGE
    local SHOW_ITEM_PROGRESS_BAR_SETTING = K.SHOW_PROGRESS_BAR
    local SHOW_ITEM_CHAPTER_TIME_LEFT_SETTING = K.SHOW_CHAPTER_TIME_LEFT
    local SHOW_ITEM_BOOK_TIME_LEFT_SETTING = K.SHOW_BOOK_TIME_LEFT
    local SHOW_ITEM_TOTAL_TIME_SETTING = K.SHOW_TOTAL_TIME
    local SHOW_ITEM_TODAY_TIME_SETTING = K.SHOW_TODAY_TIME
    local SHOW_ITEM_BATTERY_SETTING = K.SHOW_BATTERY
    local SHOW_ITEM_CLOCK_SETTING = K.SHOW_CLOCK
    local SHOW_ITEM_HIGHLIGHTS_SETTING = K.SHOW_HIGHLIGHTS
    local SHOW_ITEM_CUSTOM_MESSAGE_SETTING = K.SHOW_CUSTOM_MESSAGE

    local MAX_HIGHLIGHT_SIZE = K.MAX_HIGHLIGHT_SIZE
    local HIDE_COVER_FOR_LARGE_HIGHLIGHTS = K.HIDE_COVER_FOR_LARGE_HIGHLIGHTS
    local STATISTICS_DB_PATH = DataStorage:getSettingsDir() .. "/statistics.sqlite3"

    local CONTENT_MODE_BOOK_RECEIPT = K.CONTENT_MODE_BOOK_RECEIPT
    local CONTENT_MODE_HIGHLIGHT_PROGRESS = K.CONTENT_MODE_HIGHLIGHT_PROGRESS
    local CONTENT_MODE_RANDOM = K.CONTENT_MODE_RANDOM

    local STYLE_SWISS = K.STYLE_SWISS
    local STYLE_TERMINAL = K.STYLE_TERMINAL
    local STYLE_QUOTE = K.STYLE_QUOTE
    local STYLE_TICKET = K.STYLE_TICKET
    local STYLE_COVER = K.STYLE_COVER
    local STYLE_ZEN = K.STYLE_ZEN

    local doc_props = ui.doc_props or {}
    local book_title = doc_props.display_title or ""
    local book_author = doc_props.authors or ""
    if book_author:find("\n") then
        local authors = util.splitToArray(book_author, "\n")
        if authors and authors[1] then
            book_author = T(_("%1 et al."), authors[1] .. ",")
        end
    end

    local doc_settings = ui.doc_settings and ui.doc_settings.data or {}
    local doc_page_no = (state and state.page) or 1
    local doc_page_total = doc_settings.doc_pages or 1
    if doc_page_total <= 0 then doc_page_total = 1 end
    if doc_page_no < 1 then doc_page_no = 1 end
    if doc_page_no > doc_page_total then doc_page_no = doc_page_total end

    local page_no_numeric = doc_page_no
    local page_total_numeric = doc_page_total
    local page_no_display = tostring(page_no_numeric)
    local page_total_display = tostring(page_total_numeric)

    if ui.pagemap and ui.pagemap:wantsPageLabels() then
        local label, idx, count = ui.pagemap:getCurrentPageLabel(true)
        local last_label = ui.pagemap:getLastPageLabel(true)
        if idx and count then
            page_no_numeric = idx
            page_total_numeric = count
        end
        if label and label ~= "" then
            page_no_display = label
        else
            page_no_display = tostring(page_no_numeric)
        end
        if last_label and last_label ~= "" then
            page_total_display = last_label
        else
            page_total_display = tostring(page_total_numeric)
        end
    end

    local page_left = math.max(page_total_numeric - page_no_numeric, 0)
    local toc = ui.toc
    local chapter_title = ""
    local chapter_total = page_total_numeric
    local chapter_left = 0
    local chapter_done = 0
    if toc then
        chapter_title = toc:getTocTitleByPage(doc_page_no) or ""
        chapter_total = toc:getChapterPageCount(doc_page_no) or chapter_total
        chapter_left = toc:getChapterPagesLeft(doc_page_no) or 0
        chapter_done = toc:getChapterPagesDone(doc_page_no) or 0
    end
    chapter_total = chapter_total > 0 and chapter_total or page_total_numeric
    chapter_done = math.max(chapter_done + 1, 1)

    local statistics = ui.statistics
    local avg_time_per_page = statistics and statistics.avg_time
    local function secs_to_timestring(secs)
        if not secs then return _("calculating time") end
        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local htext = h == 1 and _("hr") or _("hrs")
        local mtext = m == 1 and _("min") or _("mins")
        if h == 0 and m > 0 then
            return string.format("%i %s", m, mtext)
        elseif h > 0 and m == 0 then
            return string.format("%i %s", h, htext)
        elseif h > 0 and m > 0 then
            return string.format("%i %s %i %s", h, htext, m, mtext)
        elseif h == 0 and m == 0 then
            return _("less than a minute")
        end
        return _("calculating time")
    end
    local function time_left(pages)
        if not avg_time_per_page then return nil end
        return avg_time_per_page * pages
    end

    local book_time_left = secs_to_timestring(time_left(page_left))
    local chapter_time_left = secs_to_timestring(time_left(chapter_left))

    local current_time = datetime.secondsToHour(os.time(), G_reader_settings:isTrue("twelve_hour_clock")) or ""

    local battery = ""
    if Device:hasBattery() then
        local power_dev = Device:getPowerDevice()
        local batt_lvl = power_dev:getCapacity() or 0
        local is_charging = power_dev:isCharging() or false
        local batt_prefix = power_dev:getBatterySymbol(power_dev:isCharged(), is_charging, batt_lvl) or ""
        battery = batt_prefix .. batt_lvl .. "%"
    else
        battery = "⚡ 100%"
    end
    if current_time == "" then
        current_time = datetime.secondsToHour(os.time(), G_reader_settings:isTrue("twelve_hour_clock")) or os.date("%H:%M")
    end

    local style = normalizeReceiptStyle(G_reader_settings:readSetting(BOOK_RECEIPT_STYLE_SETTING))
    local screen_w_raw = Screen:getWidth()
    local screen_h_raw = Screen:getHeight()
    local screen_width = math.min(screen_w_raw, screen_h_raw)
    local screen_height = math.max(screen_w_raw, screen_h_raw)
    local function scaled(value)
        return math.max(1, Screen:scaleBySize(value))
    end

    local card_ratio_mode = G_reader_settings:readSetting(CARD_RATIO_MODE_SETTING) or "default"
    local widget_width, target_card_height
    if card_ratio_mode == "fullscreen" then
        widget_width = screen_width
        target_card_height = screen_height
    else
        local widget_width_ratio = 0.60
        if card_ratio_mode == "custom" then
            local custom_val = tonumber(G_reader_settings:readSetting(CARD_RATIO_CUSTOM_SETTING)) or 0.60
            widget_width_ratio = math.max(0.30, math.min(1.00, custom_val))
        end
        widget_width = math.floor(screen_width * widget_width_ratio)
        target_card_height = math.floor(screen_height * widget_width_ratio)
    end

    local card_padding_h = (style == STYLE_SWISS) and 0 or ((card_ratio_mode == "fullscreen") and scaled(54) or scaled(36))
    local card_padding_v = (style == STYLE_SWISS) and 0 or ((card_ratio_mode == "fullscreen") and scaled(54) or scaled(36))
    local content_width = (style == STYLE_SWISS) and (widget_width - math.max(scaled(85), math.floor(widget_width * 0.32)) - scaled(48)) or (widget_width - card_padding_h * 2)

    local db_font_color = Blitbuffer.COLOR_BLACK
    local db_font_color_lighter = Blitbuffer.COLOR_GRAY_3
    local db_font_color_lightest = Blitbuffer.COLOR_GRAY_9

    local card_bg_setting = G_reader_settings:readSetting(BOOK_RECEIPT_CARD_BG_SETTING) or "light_gray"
    local db_background_color = Blitbuffer.COLOR_GRAY_E
    if card_bg_setting == "pure_white" then
        db_background_color = Blitbuffer.COLOR_WHITE
    elseif card_bg_setting == "soft_gray" then
        db_background_color = Blitbuffer.COLOR_GRAY_D
    end
    if style == STYLE_TERMINAL then
        db_font_color = Blitbuffer.COLOR_WHITE
        db_font_color_lighter = Blitbuffer.COLOR_GRAY_9
        db_font_color_lightest = Blitbuffer.COLOR_GRAY_3
        db_background_color = Blitbuffer.COLOR_BLACK
    end
    local db_font_face = "cfont"
    local db_font_face_italics = "cfont"
    local db_font_size_big = scaled(25)
    local db_font_size_mid = scaled(18)
    local db_font_size_small = scaled(15)
    local db_padding = scaled(20)
    local db_padding_internal = scaled(8)

    if style == STYLE_TERMINAL then
        db_font_size_big = scaled(23)
        db_font_size_mid = scaled(16)
        db_font_size_small = scaled(13)
        db_padding = scaled(16)
        db_padding_internal = scaled(6)
    elseif style == STYLE_TICKET then
        db_font_size_big = scaled(21)
        db_font_size_mid = scaled(16)
        db_font_size_small = scaled(13)
        db_padding = scaled(14)
        db_padding_internal = scaled(6)
    elseif style == STYLE_QUOTE then
        db_font_size_big = scaled(27)
        db_font_size_mid = scaled(17)
        db_font_size_small = scaled(14)
        db_padding = scaled(22)
        db_padding_internal = scaled(10)
    elseif style == STYLE_COVER then
        db_font_size_big = scaled(22)
        db_font_size_mid = scaled(17)
        db_font_size_small = scaled(14)
        db_padding = scaled(18)
        db_padding_internal = scaled(8)
    elseif style == STYLE_ZEN then
        db_font_size_big = scaled(24)
        db_font_size_mid = scaled(16)
        db_font_size_small = scaled(13)
        db_padding = scaled(26)
        db_padding_internal = scaled(12)
    end

    local compact_layout = screen_height < 1500 or screen_height / math.max(screen_width, 1) < 1.35
    if compact_layout then
        db_padding = math.max(scaled(10), math.floor(db_padding * 0.82))
        db_padding_internal = math.max(scaled(5), math.floor(db_padding_internal * 0.82))
    end

    local function compactBookTitle(title, max_chars)
        title = util.trim(title or "")
        local first_line = title:match("^([^\n]+)")
        if first_line and first_line ~= "" then
            title = util.trim(first_line)
        end
        local core_title = title:match("^(.-)[%(（]")
        if core_title and util.trim(core_title) ~= "" then
            title = util.trim(core_title)
        end
        local compact_title, _, was_truncated = utf8TrimToLength(title, max_chars)
        if was_truncated then
            compact_title = compact_title .. "..."
        end
        return compact_title
    end

    local title_limit = style == STYLE_ZEN and (compact_layout and 20 or 24)
            or (style == STYLE_QUOTE and (compact_layout and 24 or 30) or (compact_layout and 30 or 36))
    local book_title_display = compactBookTitle(book_title, title_limit)

    local message_text
    if Device.screen_saver_mode and G_reader_settings:isTrue("screensaver_show_message") then
        local configured_message = G_reader_settings:readSetting("screensaver_message")
        configured_message = configured_message and util.trim(configured_message)
        if configured_message and configured_message ~= "" then
            if ui and ui.bookinfo and ui.bookinfo.expandString then
                message_text = ui.bookinfo:expandString(configured_message) or configured_message
            else
                message_text = configured_message
            end
            if message_text then
                message_text = util.trim(message_text)
                if message_text == "" then
                    message_text = nil
                end
            end
        end
    end
    -- Read Item Visibility Settings
    local show_item_title = G_reader_settings:nilOrTrue(SHOW_ITEM_TITLE_SETTING)
    local show_item_author = G_reader_settings:nilOrTrue(SHOW_ITEM_AUTHOR_SETTING)
    local show_item_cover = G_reader_settings:nilOrTrue(SHOW_ITEM_COVER_SETTING)
    local show_item_chapter = G_reader_settings:nilOrTrue(SHOW_ITEM_CHAPTER_SETTING)
    local show_item_page_number = G_reader_settings:nilOrTrue(SHOW_ITEM_PAGE_NUMBER_SETTING)
    local show_item_percentage = G_reader_settings:nilOrTrue(SHOW_ITEM_PERCENTAGE_SETTING)
    local show_item_progress_bar = G_reader_settings:nilOrTrue(SHOW_ITEM_PROGRESS_BAR_SETTING)
    local show_item_chapter_time_left = G_reader_settings:nilOrTrue(SHOW_ITEM_CHAPTER_TIME_LEFT_SETTING)
    local show_item_book_time_left = G_reader_settings:nilOrTrue(SHOW_ITEM_BOOK_TIME_LEFT_SETTING)
    local show_item_total_time = G_reader_settings:nilOrTrue(SHOW_ITEM_TOTAL_TIME_SETTING)
    local show_item_today_time = G_reader_settings:nilOrTrue(SHOW_ITEM_TODAY_TIME_SETTING)
    local show_item_battery = G_reader_settings:nilOrTrue(SHOW_ITEM_BATTERY_SETTING)
    local show_item_clock = G_reader_settings:nilOrTrue(SHOW_ITEM_CLOCK_SETTING)
    local show_item_highlights = G_reader_settings:nilOrTrue(SHOW_ITEM_HIGHLIGHTS_SETTING)
    local show_item_custom_message = G_reader_settings:nilOrTrue(SHOW_ITEM_CUSTOM_MESSAGE_SETTING)

    if not show_item_title then
        book_title = ""
        book_title_display = ""
    end
    if not show_item_author then
        book_author = ""
    end
    if not show_item_chapter then
        chapter_title = nil
    end
    if not show_item_chapter_time_left then
        chapter_time_left = nil
    end
    if not show_item_book_time_left then
        book_time_left = nil
    end
    if not show_item_battery then
        battery = ""
    end
    if not show_item_clock then
        current_time = ""
    end
    if not show_item_custom_message then
        message_text = nil
    end
    if not show_item_page_number then
        page_no_display = ""
        page_total_display = ""
    end

    local function databox(typename, itemname, pages_done, pages_total, time_left_text, pages_done_display, pages_total_display, options)
        options = options or {}
        local pages_done_num = tonumber(pages_done) or 0
        local pages_total_num = tonumber(pages_total) or 0
        local denom = pages_total_num > 0 and pages_total_num or 1
        local percentage_value = math.max(math.min(pages_done_num / denom, 1), 0)
        local display_done = pages_done_display or pages_done
        local display_total = pages_total_display or pages_total

        local elements = {}
        if not options.hide_title then
            table.insert(elements, TextWidget:new{
                text = typename,
                face = Font:getFace("cfont", db_font_size_big),
                bold = true,
                fgcolor = db_font_color,
                padding = 0,
            })
            table.insert(elements, VerticalSpan:new{ width = db_padding_internal })
        end

        if not options.hide_itemname then
            table.insert(elements, TextBoxWidget:new{
                -- Metadata may contain traditional or extension characters
                -- that are missing from the Latin-oriented UI sans face.
                face = Font:getFace("cfont", db_font_size_mid),
                text = itemname,
                width = widget_width,
                fgcolor = db_font_color,
                bgcolor = db_background_color,
            })
        end

        local progressbarwidth = widget_width
        local progressbarheight = Screen:scaleBySize(5)
        if style == STYLE_TERMINAL then
            progressbarheight = scaled(4)
        elseif style == STYLE_TICKET then
            progressbarheight = scaled(3)
        elseif style == STYLE_ZEN then
            progressbarheight = scaled(2)
        elseif style == STYLE_COVER then
            progressbarheight = scaled(6)
        end
        local progress_bar = ProgressWidget:new{
            width = progressbarwidth,
            height = progressbarheight,
            percentage = percentage_value,
            margin_v = 0,
            margin_h = 0,
            radius = (style == STYLE_TICKET or style == STYLE_TERMINAL) and 0 or 20,
            bordersize = 0,
            bgcolor = db_font_color_lightest,
            fillcolor = db_font_color,
        }

        local page_progress = TextWidget:new{
            text = string.format(_("page %s of %s"), display_done, display_total),
            face = Font:getFace("cfont", db_font_size_small),
            bold = false,
            fgcolor = db_font_color_lighter,
            padding = 0,
            align = (style == STYLE_QUOTE or style == STYLE_ZEN) and "center" or "left",
        }

        local percentage_display = TextWidget:new{
            text = string.format("%i%%", math.floor(percentage_value * 100 + 0.5)),
            face = Font:getFace("cfont", db_font_size_small),
            bold = false,
            fgcolor = db_font_color_lighter,
            padding = 0,
            align = (style == STYLE_QUOTE or style == STYLE_ZEN) and "center" or "right",
        }

        if not options.hide_progress then
            table.insert(elements, VerticalSpan:new{ width = db_padding_internal })
            table.insert(elements, VerticalGroup:new{
                progress_bar,
                HorizontalGroup:new{
                    page_progress,
                    HorizontalSpan:new{ width = math.max(0, progressbarwidth - page_progress:getSize().w - percentage_display:getSize().w) },
                    percentage_display,
                },
            })
        end

        if not options.hide_time and time_left_text then
            table.insert(elements, VerticalSpan:new{ width = db_padding_internal })
            table.insert(elements, TextWidget:new{
                text = string.format(_("%s left in %s"), typename, time_left_text),
                face = Font:getFace(db_font_face_italics, db_font_size_small),
                bold = false,
                fgcolor = db_font_color,
                padding = 0,
                align = "right",
            })
        end

        if options.total_time_text then
            table.insert(elements, VerticalSpan:new{ width = db_padding_internal })
            table.insert(elements, TextWidget:new{
                text = options.total_time_text,
                face = Font:getFace(db_font_face_italics, db_font_size_small),
                bold = false,
                fgcolor = db_font_color,
                padding = 0,
                align = "right",
            })
        end

        if options.today_time_text then
            table.insert(elements, VerticalSpan:new{ width = db_padding_internal })
            table.insert(elements, TextWidget:new{
                text = options.today_time_text,
                face = Font:getFace(db_font_face_italics, db_font_size_small),
                bold = false,
                fgcolor = db_font_color,
                padding = 0,
                align = "right",
            })
        end

        table.insert(elements, VerticalSpan:new{ width = db_padding_internal })

        return VerticalGroup:new(elements)
    end

    local batt_pct_box = (show_item_battery and battery ~= "") and TextWidget:new{
        text = battery,
        face = Font:getFace("cfont", db_font_size_small - scaled(1)),
        bold = false,
        fgcolor = db_font_color_lighter,
        padding = 0,
    } or nil

    local glyph_clock = "⌚ "
    local time_box = (show_item_clock and current_time ~= "") and TextWidget:new{
        text = string.format("%s%s", glyph_clock, current_time),
        face = Font:getFace("cfont", db_font_size_small - scaled(1)),
        bold = false,
        fgcolor = db_font_color_lighter,
        padding = 0,
    } or nil

    local bottom_bar
    if batt_pct_box or time_box then
        local left_w = batt_pct_box and batt_pct_box:getSize().w or 0
        local right_w = time_box and time_box:getSize().w or 0
        bottom_bar = HorizontalGroup:new{
            batt_pct_box or HorizontalSpan:new{ width = 0 },
            HorizontalSpan:new{ width = math.max(0, widget_width - left_w - right_w) },
            time_box or HorizontalSpan:new{ width = 0 },
        }
    end

    local bookboxtitle = book_title_display
    if book_author ~= "" then
        bookboxtitle = string.format("%s - %s", book_title, book_author)
    end
    local content_mode_setting = G_reader_settings:readSetting(BOOK_RECEIPT_CONTENT_MODE_SETTING) or CONTENT_MODE_BOOK_RECEIPT
    local content_mode = content_mode_setting
    if content_mode_setting == CONTENT_MODE_RANDOM then
        local candidates = { CONTENT_MODE_BOOK_RECEIPT, CONTENT_MODE_HIGHLIGHT_PROGRESS }
        content_mode = candidates[math.random(#candidates)]
    end
    local book_total_time_text
    local book_today_time_text
    if show_item_total_time then
        local total_secs = (statistics and statistics.book_read_time) or 0
        book_total_time_text = string.format(_("Total time spent: %s"), secs_to_timestring(total_secs))
    end
    if show_item_today_time then
        local today_dur = (statistics and getBookTodayDuration(statistics)) or 0
        local day_label = getLocalizedDayName(os.time())
        book_today_time_text = string.format(_("Time spent today (%s): %s"), day_label, secs_to_timestring(today_dur))
    end

    local bookbox = databox(_("Book"), bookboxtitle, page_no_numeric, page_total_numeric, book_time_left, page_no_display, page_total_display, {
        hide_title = content_mode == CONTENT_MODE_HIGHLIGHT_PROGRESS or style == STYLE_QUOTE,
        hide_time = content_mode == CONTENT_MODE_HIGHLIGHT_PROGRESS,
        hide_progress = false,
        hide_itemname = style == STYLE_QUOTE,
        total_time_text = style ~= STYLE_TERMINAL and book_total_time_text or nil,
        today_time_text = style ~= STYLE_TERMINAL and book_today_time_text or nil,
    })
    local chapterbox = content_mode ~= CONTENT_MODE_HIGHLIGHT_PROGRESS and databox(_("Chapter"), chapter_title, chapter_done, chapter_total, chapter_time_left) or nil

    local bg_choice = G_reader_settings:readSetting(BOOK_RECEIPT_BG_SETTING)
    local user_show_cover = G_reader_settings:nilOrTrue(BOOK_RECEIPT_SHOW_COVER_SETTING) and show_item_cover
    local style_allows_cover = style == STYLE_COVER
    local show_cover = style_allows_cover and user_show_cover and not (Device.screen_saver_mode and bg_choice == "book_cover")
    local cover_widget
    if show_cover and ui.bookinfo and ui.document then
        local cover_bb = ui.bookinfo:getCoverImage(ui.document)
        if cover_bb then
			local cover_scale = tonumber(G_reader_settings:readSetting(BOOK_RECEIPT_COVER_SCALE_SETTING)) or 1
            if cover_scale > 0 then
                local cover_width = cover_bb:getWidth()
                local cover_height = cover_bb:getHeight()
                local cover_height_ratio = style == STYLE_COVER and (compact_layout and 0.38 or 0.48) or 0.26
                local max_width = math.floor((widget_width - db_padding * 2) * cover_scale)
                local max_height = math.floor(screen_height * cover_height_ratio * cover_scale)
                local scale = math.min(1, max_width / cover_width, max_height / cover_height)
                if scale < 1 then
                    local scaled_w = math.max(1, math.floor(cover_width * scale))
                    local scaled_h = math.max(1, math.floor(cover_height * scale))
                    cover_bb = RenderImage:scaleBlitBuffer(cover_bb, scaled_w, scaled_h, true)
                    cover_width = cover_bb:getWidth()
                    cover_height = cover_bb:getHeight()
                end
                cover_widget = CenterContainer:new{
                    dimen = Geom:new{ w = widget_width, h = cover_height },
                    ImageWidget:new{ image = cover_bb, width = cover_width, height = cover_height },
                }
            end
        end
    end

    local content_children = {}
    local highlight_widgets
    local highlight_length = 0
    local highlight_line_capacity = math.max(14, math.floor(widget_width / math.max(scaled(14), 1)))
    local highlight_char_limit = math.min(MAX_HIGHLIGHT_SIZE, highlight_line_capacity * (style == STYLE_QUOTE and 8 or 5))
    if show_item_highlights then
        local highlight_item = getRandomHighlightAnnotation(ui)
        if highlight_item then
            local highlight_text = util.trim(highlight_item.text or "")
            if highlight_text ~= "" then
                local truncated_text, char_count, was_truncated = utf8TrimToLength(highlight_text, highlight_char_limit)
                highlight_length = char_count
                if was_truncated then
                    truncated_text = truncated_text .. "..."
                end

                local meta_parts = {}
                if highlight_item.chapter and highlight_item.chapter ~= "" then
                    table.insert(meta_parts, highlight_item.chapter)
                end
                local highlight_page = highlight_item.pageref or highlight_item.pageno
                if not highlight_page and highlight_item.page and type(highlight_item.page) == "string" and ui.document and ui.document.getPageFromXPointer then
                    local ok, page_from_xp = pcall(ui.document.getPageFromXPointer, ui.document, highlight_item.page)
                    if ok then
                        highlight_page = page_from_xp
                    end
                end
                if highlight_page then
                    local page_label
                    if type(highlight_page) == "number" then
                        page_label = string.format(_("Page %s"), tostring(highlight_page))
                    else
                        page_label = highlight_page
                    end
                    table.insert(meta_parts, page_label)
                end
                if #meta_parts > 0 then
                    highlight_widgets = {
                        TextBoxWidget:new{
                            face = Font:getFace("cfont", db_font_size_big),
                            text = truncated_text,
                            width = widget_width,
                            fgcolor = db_font_color,
                            bgcolor = db_background_color,
                            bold = true,
                            alignment = "center",
                        },
                        VerticalSpan:new{ width = db_padding_internal },
                        TextWidget:new{
                            text = string.format("(%s)", table.concat(meta_parts, ", ")),
                            face = Font:getFace("cfont", db_font_size_small),
                            bold = false,
                            fgcolor = db_font_color_lighter,
                            padding = 0,
                            align = "center",
                        },
                    }
                else
                    highlight_widgets = {
                        TextBoxWidget:new{
                            face = Font:getFace("cfont", db_font_size_big),
                            text = truncated_text,
                            width = widget_width,
                            fgcolor = db_font_color,
                            bgcolor = db_background_color,
                            bold = true,
                            alignment = "center",
                        },
                    }
                end
            end
        end
        if not highlight_widgets then
            content_mode = CONTENT_MODE_BOOK_RECEIPT
        end
    end

    if content_mode == CONTENT_MODE_BOOK_RECEIPT then
        show_cover = style_allows_cover and user_show_cover and not (Device.screen_saver_mode and bg_choice == "book_cover")
    else
        if not user_show_cover or bg_choice == "book_cover" or highlight_length > HIDE_COVER_FOR_LARGE_HIGHLIGHTS then
            show_cover = false
        end
    end
    if style == STYLE_COVER and content_mode == CONTENT_MODE_HIGHLIGHT_PROGRESS then
        show_cover = false
    elseif style == STYLE_COVER and highlight_widgets and highlight_length > HIDE_COVER_FOR_LARGE_HIGHLIGHTS then
        show_cover = false
    end

    local function addSpacing(children, amount)
        table.insert(children, VerticalSpan:new{ width = amount or db_padding_internal })
    end

    local function addDivider(children, dashed)
        if dashed or style == STYLE_TERMINAL or style == STYLE_TICKET then
            table.insert(children, TextWidget:new{
                text = string.rep("-", math.max(12, math.floor(widget_width / math.max(scaled(8), 1)))),
                face = Font:getFace("cfont", db_font_size_small),
                fgcolor = db_font_color_lighter,
                padding = 0,
                align = "center",
            })
        else
            table.insert(children, ProgressWidget:new{
                width = widget_width,
                height = scaled(1),
                percentage = 1,
                margin_v = 0,
                margin_h = 0,
                radius = 0,
                bordersize = 0,
                bgcolor = db_font_color_lightest,
                fillcolor = db_font_color_lighter,
            })
        end
    end

    local function buildBarcodeWidget(target_width, scaled_fn)
        local bar_pattern = { 3, 1, 2, 1, 4, 1, 1, 2, 3, 1, 2, 1, 4, 1, 2, 1, 3, 1, 1, 2, 4, 1, 2, 1, 3 }
        local barcode_width = math.floor(target_width * 0.72)
        local barcode_height = scaled_fn(26)

        local total_units = 0
        for _, w in ipairs(bar_pattern) do total_units = total_units + w end
        local unit_w = math.max(1, math.floor(barcode_width / total_units))

        local bars = {}
        local is_black = true
        for _, units in ipairs(bar_pattern) do
            local bar_w = units * unit_w
            if is_black then
                table.insert(bars, ProgressWidget:new{
                    width = bar_w,
                    height = barcode_height,
                    percentage = 1,
                    margin_v = 0,
                    margin_h = 0,
                    radius = 0,
                    bordersize = 0,
                    bgcolor = Blitbuffer.COLOR_BLACK,
                    fillcolor = Blitbuffer.COLOR_BLACK,
                })
            else
                table.insert(bars, HorizontalSpan:new{ width = bar_w })
            end
            is_black = not is_black
        end

        local barcode_group = HorizontalGroup:new(bars)
        return CenterContainer:new{
            dimen = Geom:new{ w = target_width, h = barcode_height },
            barcode_group,
        }
    end

    local function generateTerminalBlockBar(percentage, total_blocks)
        total_blocks = total_blocks or 12
        local filled = math.floor((percentage / 100) * total_blocks + 0.5)
        filled = math.max(0, math.min(total_blocks, filled))
        local empty = total_blocks - filled
        return string.format("[%s%s]", string.rep("█", filled), string.rep("░", empty))
    end

    local page_total_num = tonumber(page_total_numeric) or 1
    local page_done_num = tonumber(page_no_numeric) or 0
    local overall_percentage = math.floor(math.max(0, math.min(page_done_num / math.max(page_total_num, 1), 1)) * 100 + 0.5)

    if style == STYLE_SWISS then
        local left_col_width = math.max(scaled(85), math.floor(widget_width * 0.32))
        local right_col_width = widget_width - left_col_width
        local right_padding = (card_ratio_mode == "fullscreen") and scaled(32) or scaled(20)
        local content_width = right_col_width - right_padding * 2

        local right_children = {}
        
        local date_str = os.date("%Y.%m.%d")
        table.insert(right_children, TextWidget:new{
            text = string.format("BOOK RECEIPT / %s", date_str),
            face = Font:getFace("cfont", db_font_size_small - scaled(2)),
            fgcolor = db_font_color_lighter,
            padding = 0,
        })
        table.insert(right_children, VerticalSpan:new{ width = db_padding_internal })
        table.insert(right_children, ProgressWidget:new{
            width = content_width,
            height = scaled(1),
            percentage = 1,
            margin_v = 0,
            margin_h = 0,
            radius = 0,
            bordersize = 0,
            bgcolor = db_font_color_lightest,
            fillcolor = db_font_color_lightest,
        })
        table.insert(right_children, VerticalSpan:new{ width = scaled(14) })

        local title_formatted = book_title_display
        if not title_formatted:find("^《") and not title_formatted:find("》$") then
            title_formatted = string.format("《%s》", title_formatted)
        end
        table.insert(right_children, TextBoxWidget:new{
            text = title_formatted,
            face = Font:getFace("cfont", db_font_size_big + scaled(4)),
            width = content_width,
            fgcolor = db_font_color,
            bgcolor = db_background_color,
            bold = true,
            alignment = "center",
        })
        if book_author ~= "" then
            table.insert(right_children, VerticalSpan:new{ width = scaled(4) })
            local author_txt = TextWidget:new{
                text = book_author,
                face = Font:getFace("cfont", db_font_size_small),
                fgcolor = db_font_color_lighter,
                padding = 0,
            }
            table.insert(right_children, CenterContainer:new{
                dimen = Geom:new{ w = content_width, h = author_txt:getSize().h },
                author_txt,
            })
        end

        table.insert(right_children, VerticalSpan:new{ width = scaled(24) })

        table.insert(right_children, TextWidget:new{
            text = "CURRENT PAGE",
            face = Font:getFace("cfont", db_font_size_small - scaled(2)),
            fgcolor = db_font_color_lighter,
            padding = 0,
        })
        table.insert(right_children, VerticalSpan:new{ width = scaled(6) })
        table.insert(right_children, TextWidget:new{
            text = string.format("%s  /  %s", page_no_display, page_total_display),
            face = Font:getFace("cfont", db_font_size_big + scaled(8)),
            bold = true,
            fgcolor = db_font_color,
            padding = 0,
        })
        table.insert(right_children, VerticalSpan:new{ width = scaled(10) })
        table.insert(right_children, ProgressWidget:new{
            width = content_width,
            height = scaled(12),
            percentage = overall_percentage / 100,
            margin_v = 0,
            margin_h = 0,
            radius = 0,
            bordersize = 0,
            bgcolor = db_font_color_lightest,
            fillcolor = db_font_color,
        })
        
        table.insert(right_children, VerticalSpan:new{ width = scaled(20) })
        table.insert(right_children, ProgressWidget:new{
            width = content_width,
            height = scaled(1),
            percentage = 1,
            margin_v = 0,
            margin_h = 0,
            radius = 0,
            bordersize = 0,
            bgcolor = db_font_color_lightest,
            fillcolor = db_font_color_lightest,
        })
        table.insert(right_children, VerticalSpan:new{ width = scaled(16) })

        table.insert(right_children, TextWidget:new{
            text = "CHAPTER",
            face = Font:getFace("cfont", db_font_size_small - scaled(2)),
            fgcolor = db_font_color_lighter,
            padding = 0,
        })
        table.insert(right_children, VerticalSpan:new{ width = scaled(6) })
        local chapter_display_str = (chapter_title and chapter_title ~= "") and chapter_title or "--"
        table.insert(right_children, TextBoxWidget:new{
            text = chapter_display_str,
            face = Font:getFace("cfont", db_font_size_mid + scaled(2)),
            width = content_width,
            fgcolor = db_font_color,
            bgcolor = db_background_color,
            bold = true,
        })

        if content_mode == CONTENT_MODE_HIGHLIGHT_PROGRESS and highlight_widgets then
            table.insert(right_children, VerticalSpan:new{ width = scaled(14) })
            table.insert(right_children, ProgressWidget:new{
                width = content_width,
                height = scaled(1),
                percentage = 1,
                margin_v = 0,
                margin_h = 0,
                radius = 0,
                bordersize = 0,
                bgcolor = db_font_color_lightest,
                fillcolor = db_font_color_lightest,
            })
            table.insert(right_children, VerticalSpan:new{ width = scaled(14) })
            util.arrayAppend(right_children, highlight_widgets)
        end

        table.insert(right_children, VerticalSpan:new{ width = scaled(24) })

        local today_time_str = "TODAY 0 MIN"
        local today_duration = statistics and getBookTodayDuration(statistics)
        if today_duration and today_duration > 0 then
            local mins = math.floor(today_duration / 60)
            if mins >= 60 then
                today_time_str = string.format("TODAY %d HR %d MIN", math.floor(mins / 60), mins % 60)
            else
                today_time_str = string.format("TODAY %d MIN", math.max(1, mins))
            end
        end
        local today_widget = TextWidget:new{
            text = today_time_str,
            face = Font:getFace("cfont", db_font_size_small - scaled(2)),
            fgcolor = db_font_color_lighter,
            padding = 0,
        }
        local time_widget = TextWidget:new{
            text = current_time,
            face = Font:getFace("cfont", db_font_size_small - scaled(2)),
            fgcolor = db_font_color_lighter,
            padding = 0,
        }
        local bottom_row = HorizontalGroup:new{
            today_widget,
            HorizontalSpan:new{ width = math.max(0, content_width - today_widget:getSize().w - time_widget:getSize().w) },
            time_widget,
        }
        table.insert(right_children, bottom_row)

        local swiss_v_padding = (card_ratio_mode == "fullscreen") and scaled(48) or scaled(20)
        local swiss_right_group = FrameContainer:new{
            radius = 0,
            bordersize = 0,
            padding_top = swiss_v_padding,
            padding_right = right_padding,
            padding_bottom = swiss_v_padding,
            padding_left = right_padding,
            background = db_background_color,
            VerticalGroup:new(right_children),
        }

        local swiss_target_h = target_card_height
        local right_total_height = math.max(swiss_right_group:getSize().h, swiss_target_h)
        local left_dimen = Geom:new{ w = left_col_width, h = right_total_height }

        local pct_str = string.format("%d%%", overall_percentage)
        local vertical_pct_chars = {}
        for i = 1, #pct_str do
            table.insert(vertical_pct_chars, pct_str:sub(i, i))
        end
        local vertical_pct_text = table.concat(vertical_pct_chars, "\n")

        local swiss_left_group = OverlapGroup:new{
            dimen = left_dimen,
            ProgressWidget:new{
                width = left_col_width,
                height = right_total_height,
                percentage = 1,
                margin_v = 0,
                margin_h = 0,
                radius = 0,
                bordersize = 0,
                bgcolor = Blitbuffer.COLOR_BLACK,
                fillcolor = Blitbuffer.COLOR_BLACK,
            },
            VerticalGroup:new{
                VerticalSpan:new{ width = scaled(20) },
                CenterContainer:new{
                    dimen = Geom:new{ w = left_col_width, h = scaled(20) },
                    TextWidget:new{
                        text = "READ",
                        bold = true,
                        fgcolor = Blitbuffer.COLOR_WHITE,
                        padding = 0,
                        face = Font:getFace("cfont", db_font_size_small),
                    },
                },
                CenterContainer:new{
                    dimen = Geom:new{ w = left_col_width, h = math.max(scaled(40), right_total_height - scaled(50)) },
                    TextWidget:new{
                        text = vertical_pct_text,
                        bold = true,
                        fgcolor = Blitbuffer.COLOR_WHITE,
                        padding = 0,
                        face = Font:getFace("cfont", db_font_size_big + scaled(4)),
                    },
                },
            },
        }

        table.insert(content_children, HorizontalGroup:new{
            swiss_left_group,
            swiss_right_group,
        })
    elseif style == STYLE_TERMINAL then
        table.insert(content_children, TextWidget:new{
            text = "BOOK_RECEIPT // SLEEP_MODE",
            face = Font:getFace("cfont", db_font_size_small),
            bold = true,
            fgcolor = Blitbuffer.COLOR_WHITE,
            padding = 0,
            align = "left",
        })
        addSpacing(content_children, scaled(28))

        table.insert(content_children, TextWidget:new{
            text = string.format("%d%%", overall_percentage),
            face = Font:getFace("cfont", db_font_size_big + scaled(22)),
            bold = true,
            fgcolor = Blitbuffer.COLOR_WHITE,
            padding = 0,
            align = "left",
        })
        addSpacing(content_children, scaled(24))

        local terminal_bar_str = generateTerminalBlockBar(overall_percentage, compact_layout and 12 or 16)
        table.insert(content_children, TextWidget:new{
            text = terminal_bar_str,
            face = Font:getFace("cfont", db_font_size_mid + scaled(4)),
            bold = true,
            fgcolor = Blitbuffer.COLOR_WHITE,
            padding = 0,
            align = "left",
        })
        addSpacing(content_children, scaled(32))

        local clean_title = book_title_display:gsub("^《", ""):gsub("》$", "")
        table.insert(content_children, TextBoxWidget:new{
            text = string.format("title:  %s", clean_title),
            face = Font:getFace("cfont", db_font_size_mid + scaled(2)),
            width = content_width,
            fgcolor = Blitbuffer.COLOR_WHITE,
            bgcolor = Blitbuffer.COLOR_BLACK,
        })
        if book_author ~= "" then
            addSpacing(content_children, scaled(8))
            table.insert(content_children, TextBoxWidget:new{
                text = string.format("author: %s", book_author),
                face = Font:getFace("cfont", db_font_size_small + scaled(2)),
                width = content_width,
                fgcolor = Blitbuffer.COLOR_GRAY_9,
                bgcolor = Blitbuffer.COLOR_BLACK,
            })
        end
        if content_mode ~= CONTENT_MODE_HIGHLIGHT_PROGRESS and chapter_title and chapter_title ~= "" then
            addSpacing(content_children, scaled(8))
            table.insert(content_children, TextBoxWidget:new{
                text = string.format("chapter: %s", chapter_title),
                face = Font:getFace("cfont", db_font_size_small + scaled(2)),
                width = content_width,
                fgcolor = Blitbuffer.COLOR_GRAY_9,
                bgcolor = Blitbuffer.COLOR_BLACK,
            })
        elseif highlight_widgets then
            addSpacing(content_children, scaled(16))
            util.arrayAppend(content_children, highlight_widgets)
        end

        addSpacing(content_children, scaled(40))

        local status_str = string.format("status: reading (%s / %s p)", page_no_display, page_total_display)
        table.insert(content_children, TextWidget:new{
            text = status_str,
            face = Font:getFace("cfont", db_font_size_small + scaled(2)),
            fgcolor = Blitbuffer.COLOR_WHITE,
            padding = 0,
            align = "left",
        })
    elseif style == STYLE_QUOTE then
        table.insert(content_children, TextWidget:new{
            text = "“",
            face = Font:getFace("cfont", db_font_size_big + scaled(32)),
            bold = true,
            fgcolor = db_font_color,
            padding = 0,
            align = "left",
        })
        addSpacing(content_children, scaled(16))

        local quote_text
        local highlight_item = getRandomHighlightAnnotation(ui)
        if highlight_item and highlight_item.text then
            local trimmed = util.trim(highlight_item.text)
            if trimmed ~= "" then
                local truncated_text, _, was_truncated = utf8TrimToLength(trimmed, highlight_char_limit)
                if was_truncated then
                    truncated_text = truncated_text .. "..."
                end
                quote_text = truncated_text
            end
        end
        if not quote_text or quote_text == "" then
            quote_text = "人真正要走的路，\n往往不是最热闹的\n那一条。"
        end

        table.insert(content_children, TextBoxWidget:new{
            text = quote_text,
            face = Font:getFace("cfont", db_font_size_big + scaled(4)),
            width = content_width,
            fgcolor = db_font_color,
            bgcolor = db_background_color,
            bold = true,
            alignment = "left",
        })

        addSpacing(content_children, scaled(24))
        table.insert(content_children, ProgressWidget:new{
            width = content_width,
            height = scaled(2),
            percentage = 1,
            margin_v = 0,
            margin_h = 0,
            radius = 0,
            bordersize = 0,
            bgcolor = db_font_color,
            fillcolor = db_font_color,
        })
        addSpacing(content_children, scaled(16))

        local clean_title = book_title_display:gsub("^《", ""):gsub("》$", "")
        local cite_str = string.format("《%s》", clean_title)
        if chapter_title and chapter_title ~= "" then
            cite_str = string.format("《%s》  ·  %s", clean_title, chapter_title)
        end
        table.insert(content_children, TextWidget:new{
            text = cite_str,
            face = Font:getFace("cfont", db_font_size_small + scaled(2)),
            fgcolor = db_font_color_lighter,
            padding = 0,
            align = "left",
        })
        if book_author ~= "" then
            addSpacing(content_children, scaled(4))
            table.insert(content_children, TextWidget:new{
                text = book_author,
                face = Font:getFace("cfont", db_font_size_small + scaled(2)),
                fgcolor = db_font_color_lighter,
                padding = 0,
                align = "left",
            })
        end

        addSpacing(content_children, scaled(36))
        table.insert(content_children, TextWidget:new{
            text = string.format("%s  /  %s", page_no_display, page_total_display),
            face = Font:getFace("cfont", db_font_size_mid + scaled(2)),
            fgcolor = db_font_color,
            padding = 0,
            align = "left",
        })
        addSpacing(content_children, scaled(10))
        table.insert(content_children, ProgressWidget:new{
            width = content_width,
            height = scaled(12),
            percentage = overall_percentage / 100,
            margin_v = 0,
            margin_h = 0,
            radius = 0,
            bordersize = 0,
            bgcolor = db_font_color_lightest,
            fillcolor = db_font_color,
        })
    elseif style == STYLE_TICKET then
        local ticket_title_widget = TextWidget:new{
            text = "READING TICKET",
            face = Font:getFace("cfont", db_font_size_small),
            fgcolor = db_font_color_lighter,
            padding = 0,
        }
        local ticket_no_widget = TextWidget:new{
            text = string.format("NO. %04d", math.max(0, page_done_num)),
            face = Font:getFace("cfont", db_font_size_small),
            fgcolor = db_font_color,
            padding = 0,
        }
        table.insert(content_children, HorizontalGroup:new{
            ticket_title_widget,
            HorizontalSpan:new{ width = math.max(0, content_width - ticket_title_widget:getSize().w - ticket_no_widget:getSize().w) },
            ticket_no_widget,
        })
        addSpacing(content_children, scaled(10))

        table.insert(content_children, TextWidget:new{
            text = string.rep("-", math.max(16, math.floor(content_width / math.max(scaled(8), 1)))),
            face = Font:getFace("cfont", db_font_size_small),
            fgcolor = db_font_color_lightest,
            padding = 0,
            align = "center",
        })
        addSpacing(content_children, scaled(20))

        local pct_widget = TextWidget:new{
            text = string.format("%d%%", overall_percentage),
            face = Font:getFace("cfont", db_font_size_big + scaled(16)),
            bold = true,
            fgcolor = db_font_color,
            padding = 0,
        }
        local admitted_widget = TextWidget:new{
            text = "ADMITTED",
            face = Font:getFace("cfont", db_font_size_small - scaled(2)),
            fgcolor = db_font_color_lighter,
            padding = 0,
        }
        table.insert(content_children, HorizontalGroup:new{
            pct_widget,
            HorizontalSpan:new{ width = math.max(0, content_width - pct_widget:getSize().w - admitted_widget:getSize().w) },
            admitted_widget,
        })
        addSpacing(content_children, scaled(20))

        local clean_title = book_title_display:gsub("^《", ""):gsub("》$", "")
        table.insert(content_children, TextBoxWidget:new{
            text = clean_title,
            face = Font:getFace("cfont", db_font_size_big + scaled(4)),
            width = content_width,
            fgcolor = db_font_color,
            bgcolor = db_background_color,
            bold = true,
        })
        if book_author ~= "" then
            addSpacing(content_children, scaled(4))
            table.insert(content_children, TextWidget:new{
                text = book_author,
                face = Font:getFace("cfont", db_font_size_small + scaled(2)),
                fgcolor = db_font_color_lighter,
                padding = 0,
                align = "left",
            })
        end

        addSpacing(content_children, scaled(24))
        table.insert(content_children, ProgressWidget:new{
            width = content_width,
            height = scaled(1),
            percentage = 1,
            margin_v = 0,
            margin_h = 0,
            radius = 0,
            bordersize = 0,
            bgcolor = db_font_color_lightest,
            fillcolor = db_font_color_lightest,
        })
        addSpacing(content_children, scaled(20))

        local page_label = TextWidget:new{
            text = "PAGE",
            face = Font:getFace("cfont", db_font_size_small),
            fgcolor = db_font_color_lighter,
            padding = 0,
        }
        local page_val = TextWidget:new{
            text = string.format("%s  /  %s", page_no_display, page_total_display),
            face = Font:getFace("cfont", db_font_size_mid + scaled(2)),
            fgcolor = db_font_color,
            padding = 0,
        }
        table.insert(content_children, HorizontalGroup:new{
            page_label,
            HorizontalSpan:new{ width = math.max(0, content_width - page_label:getSize().w - page_val:getSize().w) },
            page_val,
        })
        addSpacing(content_children, scaled(14))

        local time_today_label = TextWidget:new{
            text = "TIME TODAY",
            face = Font:getFace("cfont", db_font_size_small),
            fgcolor = db_font_color_lighter,
            padding = 0,
        }
        local today_dur_sec = statistics and getBookTodayDuration(statistics) or 0
        local dur_h = math.floor(today_dur_sec / 3600)
        local dur_m = math.floor((today_dur_sec % 3600) / 60)
        local time_today_val_str = string.format("%02d:%02d", dur_h, dur_m)
        local time_today_val = TextWidget:new{
            text = time_today_val_str,
            face = Font:getFace("cfont", db_font_size_mid + scaled(2)),
            fgcolor = db_font_color,
            padding = 0,
        }
        table.insert(content_children, HorizontalGroup:new{
            time_today_label,
            HorizontalSpan:new{ width = math.max(0, content_width - time_today_label:getSize().w - time_today_val:getSize().w) },
            time_today_val,
        })

        if highlight_widgets then
            addSpacing(content_children, scaled(14))
            util.arrayAppend(content_children, highlight_widgets)
        end

        addSpacing(content_children, scaled(20))
        table.insert(content_children, buildBarcodeWidget(content_width, scaled))
        addSpacing(content_children, scaled(16))

        table.insert(content_children, TextWidget:new{
            text = "KEEP THIS TICKET FOR YOUR NEXT SESSION",
            face = Font:getFace("cfont", db_font_size_small - scaled(2)),
            fgcolor = db_font_color_lighter,
            padding = 0,
            align = "left",
        })
    elseif style == STYLE_COVER then
        table.insert(content_children, TextWidget:new{
            text = "NOW READING",
            face = Font:getFace("cfont", db_font_size_small - scaled(2)),
            fgcolor = db_font_color_lighter,
            padding = 0,
            align = "left",
        })
        addSpacing(content_children, scaled(16))

        local display_cover = cover_widget
        if not display_cover or not show_cover then
            local clean_title = book_title_display:gsub("^《", ""):gsub("》$", "")
            local cover_box_width = math.floor(widget_width * 0.85)
            local cover_box_height = math.floor(screen_height * 0.36)
            display_cover = OverlapGroup:new{
                dimen = Geom:new{ w = cover_box_width, h = cover_box_height },
                ProgressWidget:new{
                    width = cover_box_width,
                    height = cover_box_height,
                    percentage = 1,
                    margin_v = 0,
                    margin_h = 0,
                    radius = scaled(4),
                    bordersize = 0,
                    bgcolor = Blitbuffer.COLOR_BLACK,
                    fillcolor = Blitbuffer.COLOR_BLACK,
                },
                CenterContainer:new{
                    dimen = Geom:new{ w = cover_box_width, h = cover_box_height },
                    TextBoxWidget:new{
                        text = clean_title,
                        face = Font:getFace("cfont", db_font_size_big),
                        width = cover_box_width - scaled(32),
                        fgcolor = Blitbuffer.COLOR_WHITE,
                        bgcolor = Blitbuffer.COLOR_BLACK,
                        bold = true,
                        alignment = "center",
                    },
                },
            }
        end
        table.insert(content_children, CenterContainer:new{
            dimen = Geom:new{ w = content_width, h = display_cover:getSize().h },
            display_cover,
        })
        addSpacing(content_children, scaled(24))

        local page_num_widget = TextWidget:new{
            text = string.format("%s / %s", page_no_display, page_total_display),
            face = Font:getFace("cfont", db_font_size_big + scaled(4)),
            bold = true,
            fgcolor = db_font_color,
            padding = 0,
        }
        local pct_right_widget = TextWidget:new{
            text = string.format("%d%%", overall_percentage),
            face = Font:getFace("cfont", db_font_size_mid),
            fgcolor = db_font_color_lighter,
            padding = 0,
        }
        table.insert(content_children, HorizontalGroup:new{
            page_num_widget,
            HorizontalSpan:new{ width = math.max(0, content_width - page_num_widget:getSize().w - pct_right_widget:getSize().w) },
            pct_right_widget,
        })
        addSpacing(content_children, scaled(10))

        table.insert(content_children, ProgressWidget:new{
            width = content_width,
            height = scaled(12),
            percentage = overall_percentage / 100,
            margin_v = 0,
            margin_h = 0,
            radius = 0,
            bordersize = 0,
            bgcolor = db_font_color_lightest,
            fillcolor = db_font_color,
        })
        addSpacing(content_children, scaled(14))

        local chapter_display_str = (chapter_title and chapter_title ~= "") and chapter_title or "--"
        table.insert(content_children, TextWidget:new{
            text = chapter_display_str,
            face = Font:getFace("cfont", db_font_size_small + scaled(2)),
            fgcolor = db_font_color_lighter,
            padding = 0,
            align = "left",
        })
        if highlight_widgets then
            addSpacing(content_children, scaled(14))
            util.arrayAppend(content_children, highlight_widgets)
        end
    elseif style == STYLE_ZEN then
        local zen_date_str = os.date("%m / %d")
        table.insert(content_children, HorizontalGroup:new{
            HorizontalSpan:new{ width = math.max(0, content_width - scaled(64)) },
            TextWidget:new{
                text = zen_date_str,
                face = Font:getFace("cfont", db_font_size_small + scaled(2)),
                fgcolor = db_font_color_lighter,
                padding = 0,
            },
        })
        addSpacing(content_children, scaled(16))

        local circle_size = scaled(130)
        local circle_badge = CenterContainer:new{
            dimen = Geom:new{ w = circle_size, h = circle_size },
            FrameContainer:new{
                radius = math.floor(circle_size / 2),
                bordersize = 0,
                padding = 0,
                background = Blitbuffer.COLOR_BLACK,
                CenterContainer:new{
                    dimen = Geom:new{ w = circle_size, h = circle_size },
                    VerticalGroup:new{
                        CenterContainer:new{
                            dimen = Geom:new{ w = circle_size, h = scaled(46) },
                            TextWidget:new{
                                text = tostring(overall_percentage),
                                face = Font:getFace("cfont", db_font_size_big + scaled(16)),
                                bold = true,
                                fgcolor = Blitbuffer.COLOR_WHITE,
                                padding = 0,
                            },
                        },
                        CenterContainer:new{
                            dimen = Geom:new{ w = circle_size, h = scaled(20) },
                            TextWidget:new{
                                text = "PERCENT",
                                face = Font:getFace("cfont", db_font_size_small - scaled(3)),
                                fgcolor = Blitbuffer.COLOR_WHITE,
                                padding = 0,
                            },
                        },
                    },
                },
            },
        }

        local clean_title = book_title_display:gsub("^《", ""):gsub("》$", "")
        local title_box_width = content_width - circle_size - scaled(28)

        local title_widget = TextBoxWidget:new{
            text = clean_title,
            face = Font:getFace("cfont", db_font_size_big + scaled(10)),
            width = title_box_width,
            fgcolor = db_font_color,
            bgcolor = db_background_color,
            bold = true,
        }

        local author_widget
        if book_author ~= "" then
            author_widget = TextBoxWidget:new{
                text = string.format("—— %s", book_author),
                face = Font:getFace("cfont", db_font_size_small + scaled(2)),
                width = title_box_width,
                fgcolor = db_font_color_lighter,
                bgcolor = db_background_color,
            }
        end

        local title_author_items = { title_widget }
        if author_widget then
            table.insert(title_author_items, VerticalSpan:new{ width = scaled(8) })
            table.insert(title_author_items, author_widget)
        end
        local title_author_group = VerticalGroup:new(title_author_items)

        table.insert(content_children, HorizontalGroup:new{
            circle_badge,
            HorizontalSpan:new{ width = scaled(24) },
            CenterContainer:new{
                dimen = Geom:new{ w = title_box_width, h = math.max(circle_size, title_author_group:getSize().h) },
                title_author_group,
            },
        })
        addSpacing(content_children, scaled(24))

        table.insert(content_children, ProgressWidget:new{
            width = content_width,
            height = scaled(1),
            percentage = 1,
            margin_v = 0,
            margin_h = 0,
            radius = 0,
            bordersize = 0,
            bgcolor = db_font_color_lightest,
            fillcolor = db_font_color_lightest,
        })
        addSpacing(content_children, scaled(20))

        local chapter_display_str = (chapter_title and chapter_title ~= "") and chapter_title or "--"
        table.insert(content_children, TextWidget:new{
            text = chapter_display_str,
            face = Font:getFace("cfont", db_font_size_mid + scaled(4)),
            bold = true,
            fgcolor = db_font_color,
            padding = 0,
            align = "left",
        })
        addSpacing(content_children, scaled(10))

        table.insert(content_children, TextWidget:new{
            text = string.format("%s  /  %s", page_no_display, page_total_display),
            face = Font:getFace("cfont", db_font_size_mid),
            fgcolor = db_font_color_lighter,
            padding = 0,
            align = "left",
        })
        if highlight_widgets then
            addSpacing(content_children, scaled(14))
            util.arrayAppend(content_children, highlight_widgets)
        end
        addSpacing(content_children, scaled(24))

        table.insert(content_children, TextWidget:new{
            text = "静下来，继续读。",
            face = Font:getFace("cfont", db_font_size_small + scaled(2)),
            fgcolor = db_font_color_lighter,
            padding = 0,
            align = "left",
        })
    end

    if style ~= STYLE_SWISS then
        if message_text then
            table.insert(content_children, VerticalSpan:new{ width = db_padding_internal })
            table.insert(content_children, VerticalGroup:new{
                TextBoxWidget:new{
                    face = Font:getFace(db_font_face, db_font_size_mid),
                    text = message_text,
                    width = content_width,
                    fgcolor = db_font_color,
                    bgcolor = db_background_color,
                    bold = true,
                    alignment = "center",
                },
                VerticalSpan:new{ width = db_padding_internal },
            })
        end
        if bottom_bar then
            table.insert(content_children, VerticalSpan:new{ width = db_padding_internal })
            table.insert(content_children, bottom_bar)
        end
    end

    local frame_radius = 0
    local frame_bordersize = 0
    local frame_padding_top = card_padding_v
    local frame_padding_right = card_padding_h
    local frame_padding_bottom = card_padding_v
    local frame_padding_left = card_padding_h
    local frame_background = db_background_color
    if style == STYLE_TERMINAL then
        frame_bordersize = 0
        frame_background = Blitbuffer.COLOR_BLACK
    elseif style == STYLE_TICKET then
        frame_bordersize = 0
        frame_radius = 0
    elseif style == STYLE_SWISS then
        frame_bordersize = 0
        frame_padding_top = 0
        frame_padding_right = 0
        frame_padding_bottom = 0
        frame_padding_left = 0
    elseif style == STYLE_QUOTE then
        frame_bordersize = 0
        frame_radius = 0
    elseif style == STYLE_COVER then
        frame_bordersize = 0
        frame_radius = scaled(4)
    elseif style == STYLE_ZEN then
        frame_bordersize = 0
    end

    local content_inner_widget = VerticalGroup:new(content_children)
    local current_inner_h = content_inner_widget:getSize().h
    local target_inner_h = math.max(current_inner_h, target_card_height - frame_padding_top - frame_padding_bottom)

    local card_body_widget
    if target_inner_h > current_inner_h and style ~= STYLE_SWISS then
        card_body_widget = CenterContainer:new{
            dimen = Geom:new{ w = widget_width - frame_padding_left - frame_padding_right, h = target_inner_h },
            content_inner_widget,
        }
    else
        card_body_widget = content_inner_widget
    end

    local border_setting = G_reader_settings:readSetting(BOOK_RECEIPT_BORDER_SETTING) or "none"
    if border_setting == "thin" then
        frame_bordersize = scaled(1)
    elseif border_setting == "thick" then
        frame_bordersize = scaled(2)
    end

    local final_frame = FrameContainer:new{
        radius = frame_radius,
        bordersize = frame_bordersize,
        padding_top = frame_padding_top,
        padding_right = frame_padding_right,
        padding_bottom = frame_padding_bottom,
        padding_left = frame_padding_left,
        background = frame_background,
        card_body_widget,
    }

    local show_shadow = G_reader_settings:isTrue(BOOK_RECEIPT_SHADOW_SETTING) and style ~= STYLE_TERMINAL and style ~= STYLE_SWISS
    if show_shadow then
        local shadow_off = scaled(10)
        local frame_size = final_frame:getSize()
        local shadow_block = ProgressWidget:new{
            width = frame_size.w,
            height = frame_size.h,
            percentage = 1,
            margin_v = 0,
            margin_h = 0,
            radius = frame_radius,
            bordersize = 0,
            bgcolor = Blitbuffer.COLOR_GRAY_3,
            fillcolor = Blitbuffer.COLOR_GRAY_3,
        }
        local total_w = frame_size.w + shadow_off
        local total_h = frame_size.h + shadow_off
        final_frame = OverlapGroup:new{
            dimen = Geom:new{ w = total_w, h = total_h },
            CenterContainer:new{
                dimen = Geom:new{ w = total_w, h = total_h },
                VerticalGroup:new{
                    VerticalSpan:new{ width = shadow_off },
                    HorizontalGroup:new{
                        HorizontalSpan:new{ width = shadow_off },
                        shadow_block,
                    },
                },
            },
            CenterContainer:new{
                dimen = Geom:new{ w = total_w, h = total_h },
                VerticalGroup:new{
                    HorizontalGroup:new{
                        final_frame,
                        HorizontalSpan:new{ width = shadow_off },
                    },
                    VerticalSpan:new{ width = shadow_off },
                },
            },
        }
    end

    return CenterContainer:new{
        dimen = Screen:getSize(),
        final_frame,
    }
end

local quicklookbox = InputContainer:extend{  
    modal = true,  
    name = "quick_look_box",  
    covers_fullscreen = true,
}  

function quicklookbox:init()
    local receipt_widget = buildReceipt(self.ui, self.state)
    if receipt_widget then
        self[1] = composeQuickLookReceipt(self.ui, receipt_widget)
    else
        self[1] = CenterContainer:new{
            dimen = Screen:getSize(),
            TextWidget:new{
                text = _("Receipt unavailable"),
                face = Font:getFace("cfont", 20),
            },
        }
    end

    if Device:hasKeys() then
        self.key_events.AnyKeyPressed = { { Device.input.group.Any } }
    end
    if Device:isTouchDevice() then
        self.ges_events.Swipe = {
            GestureRange:new{
                ges = "swipe",
                range = function() return self.dimen end,
            }
        }
        self.ges_events.Tap = {
            GestureRange:new{
                ges = "tap",
                range = function() return self.dimen end,
            }
        }
        self.ges_events.MultiSwipe = {
            GestureRange:new{
                ges = "multiswipe",
                range = function() return self.dimen end,
            }
        }
    end
end

function quicklookbox:onTap()
    UIManager:close(self)
end

function quicklookbox:onSwipe(arg, ges_ev)
    if ges_ev.direction == "south" then
        -- Allow easier closing with swipe up/down
        self:onClose()
    elseif ges_ev.direction == "east" or ges_ev.direction == "west" or ges_ev.direction == "north" then
        self:onClose()-- -- no use for now
        -- do end -- luacheck: ignore 541
    else -- diagonal swipe
		self:onClose()

    end
end

function quicklookbox:onClose()
    UIManager:close(self)
    return true
end

quicklookbox.onAnyKeyPressed = quicklookbox.onClose

quicklookbox.onMultiSwipe = quicklookbox.onClose

-- add to dispatcher

Dispatcher:registerAction("quicklookbox_action", {
							category="none", 
							event="QuickLook", 
							title=_("Book receipt"), 
							reader=true,})

function ReaderUI:onQuickLook()
    local ui = self
    UIManager:nextTick(function()
        if not ui then return end
        local widget = quicklookbox:new{
            ui = ui,
            document = ui.document,
            state = ui.view and ui.view.state,
        }
        UIManager:show(widget)
    end)
end

-- Screensaver integration

local Screensaver = require("ui/screensaver")

local orig_screensaver_show = Screensaver.show

Screensaver.show = function(self)
    if self.screensaver_type ~= "book_receipt" then
        return orig_screensaver_show(self)
    end

    local ui = self.ui or ReaderUI.instance
    if not hasActiveDocument(ui) then
        showFallbackScreensaver(self, orig_screensaver_show)
        return
    end

    if self.screensaver_widget then
        UIManager:close(self.screensaver_widget)
        self.screensaver_widget = nil
    end

    Device.screen_saver_mode = true

    local rotation_mode = Screen:getRotationMode()
    Device.orig_rotation_mode = rotation_mode
    if bit.band(rotation_mode, 1) == 1 then
        Screen:setRotationMode(Screen.DEVICE_ROTATED_UPRIGHT)
    else
        Device.orig_rotation_mode = nil
    end

    local state = ui and ui.view and ui.view.state
    local receipt_widget = buildReceipt(ui, state)

    if receipt_widget then
        local background_color, background_widget = getReceiptBackground(ui)
        if normalizeReceiptStyle(G_reader_settings:readSetting(BOOK_RECEIPT_STYLE_SETTING)) == STYLE_TERMINAL
                and not background_widget then
            background_color = Blitbuffer.COLOR_BLACK
        end
        local widget_to_show = receipt_widget

        if background_widget then
            widget_to_show = OverlapGroup:new{
                dimen = Screen:getSize(),
                background_widget,
                receipt_widget,
            }
        end

        self.screensaver_widget = ScreenSaverWidget:new{
            widget = widget_to_show,
            background = background_color,
            covers_fullscreen = true,
        }
        self.screensaver_widget.modal = true
        self.screensaver_widget.dithered = true
        UIManager:show(self.screensaver_widget, "full")
    else
        logger.warn("Book receipt: failed to build widget, falling back to default screensaver")
        showFallbackScreensaver(self, orig_screensaver_show)
    end
end

-- Add screensaver menu option

local orig_dofile = dofile

_G.dofile = function(filepath)
    local result = orig_dofile(filepath)

    if filepath and filepath:match("screensaver_menu%.lua$") then

        if result and result[1] and result[1].sub_item_table then
            local wallpaper_submenu = result[1].sub_item_table

            local BOOK_RECEIPT_BG_SETTING = K.BG_SETTING
            local BOOK_RECEIPT_BG_IMAGE_MODE_SETTING = K.BG_IMAGE_MODE_SETTING
            local BOOK_RECEIPT_CONTENT_MODE_SETTING = K.CONTENT_MODE_SETTING
            local BOOK_RECEIPT_COVER_SCALE_SETTING = K.COVER_SCALE_SETTING
            local BOOK_RECEIPT_SHOW_COVER_SETTING = K.SHOW_COVER_SETTING
            local BOOK_RECEIPT_STYLE_SETTING = K.STYLE_SETTING
            local CARD_RATIO_MODE_SETTING = K.CARD_RATIO_MODE
            local CARD_RATIO_CUSTOM_SETTING = K.CARD_RATIO_CUSTOM
            local BOOK_RECEIPT_BORDER_SETTING = K.BORDER
            local BOOK_RECEIPT_CARD_BG_SETTING = K.CARD_BG
            local BOOK_RECEIPT_SHADOW_SETTING = K.SHADOW

            local SHOW_ITEM_TITLE_SETTING = K.SHOW_TITLE
            local SHOW_ITEM_AUTHOR_SETTING = K.SHOW_AUTHOR
            local SHOW_ITEM_COVER_SETTING = K.SHOW_COVER
            local SHOW_ITEM_CHAPTER_SETTING = K.SHOW_CHAPTER
            local SHOW_ITEM_PAGE_NUMBER_SETTING = K.SHOW_PAGE_NUMBER
            local SHOW_ITEM_PERCENTAGE_SETTING = K.SHOW_PERCENTAGE
            local SHOW_ITEM_PROGRESS_BAR_SETTING = K.SHOW_PROGRESS_BAR
            local SHOW_ITEM_CHAPTER_TIME_LEFT_SETTING = K.SHOW_CHAPTER_TIME_LEFT
            local SHOW_ITEM_BOOK_TIME_LEFT_SETTING = K.SHOW_BOOK_TIME_LEFT
            local SHOW_ITEM_TOTAL_TIME_SETTING = K.SHOW_TOTAL_TIME
            local SHOW_ITEM_TODAY_TIME_SETTING = K.SHOW_TODAY_TIME
            local SHOW_ITEM_BATTERY_SETTING = K.SHOW_BATTERY
            local SHOW_ITEM_CLOCK_SETTING = K.SHOW_CLOCK
            local SHOW_ITEM_HIGHLIGHTS_SETTING = K.SHOW_HIGHLIGHTS
            local SHOW_ITEM_CUSTOM_MESSAGE_SETTING = K.SHOW_CUSTOM_MESSAGE

            local STYLE_SWISS = K.STYLE_SWISS
            local STYLE_TERMINAL = K.STYLE_TERMINAL
            local STYLE_QUOTE = K.STYLE_QUOTE
            local STYLE_TICKET = K.STYLE_TICKET
            local STYLE_COVER = K.STYLE_COVER
            local STYLE_ZEN = K.STYLE_ZEN

            local function genMenuItem(text, setting, value, enabled_func, separator)
                return {
                    text = text,
                    enabled_func = enabled_func,
                    checked_func = function()
                        return G_reader_settings:readSetting(setting) == value
                    end,
                    callback = function()
                        G_reader_settings:saveSetting(setting, value)
                    end,
                    radio = true,
                    separator = separator,
                }
            end

            local function isBookReceiptEnabled()
                return G_reader_settings:readSetting("screensaver_type") == "book_receipt"
            end

            table.insert(wallpaper_submenu, 6,
                genMenuItem(_("Show book receipt on sleep screen"), "screensaver_type", "book_receipt")
            )

            local background_menu = {
                text = _("Background"),
                sub_item_table = {
                    genMenuItem(_("White fill"), BOOK_RECEIPT_BG_SETTING, "white"),
                    genMenuItem(_("Transparent"), BOOK_RECEIPT_BG_SETTING, "transparent"),
                    genMenuItem(_("Black fill"), BOOK_RECEIPT_BG_SETTING, "black"),
                    genMenuItem(_("Random image"), BOOK_RECEIPT_BG_SETTING, "random_image"),
                    genMenuItem(_("Book cover"), BOOK_RECEIPT_BG_SETTING, "book_cover"),
                    {
                        text = _("Background image placement"),
                        enabled_func = function()
                            local value = G_reader_settings:readSetting(BOOK_RECEIPT_BG_SETTING)
                            return value == "random_image" or value == "book_cover"
                        end,
                        sub_item_table = {
                            genMenuItem(_("Fit to screen"), BOOK_RECEIPT_BG_IMAGE_MODE_SETTING, "fit"),
                            genMenuItem(_("Stretch to screen"), BOOK_RECEIPT_BG_IMAGE_MODE_SETTING, "stretch"),
                            genMenuItem(_("Center without scaling"), BOOK_RECEIPT_BG_IMAGE_MODE_SETTING, "center"),
                        },
                    },
                },
            }

            local function isStyle(value)
                local current = normalizeReceiptStyle(G_reader_settings:readSetting(BOOK_RECEIPT_STYLE_SETTING))
                return current == value
            end

            local function styleMenuItem(text, value)
                return {
                    text = text,
                    checked_func = function() return isStyle(value) end,
                    callback = function()
                        G_reader_settings:saveSetting(BOOK_RECEIPT_STYLE_SETTING, value)
                    end,
                    radio = true,
                }
            end

            local style_menu = {
                text = _("Style"),
                sub_item_table = {
                    styleMenuItem(_("Swiss grid"), STYLE_SWISS),
                    styleMenuItem(_("Terminal"), STYLE_TERMINAL),
                    styleMenuItem(_("Quote poster"), STYLE_QUOTE),
                    styleMenuItem(_("Ticket stub"), STYLE_TICKET),
                    styleMenuItem(_("Cover first"), STYLE_COVER),
                    styleMenuItem(_("Japanese minimal"), STYLE_ZEN),
                },
            }

            local function isRatioMode(val)
                local cur = G_reader_settings:readSetting(CARD_RATIO_MODE_SETTING) or "default"
                return cur == val
            end

            local ratio_menu = {
                text = _("Card width mode"),
                sub_item_table = {
                    {
                        text = _("Default ratio"),
                        checked_func = function() return isRatioMode("default") end,
                        callback = function()
                            G_reader_settings:saveSetting(CARD_RATIO_MODE_SETTING, "default")
                        end,
                        radio = true,
                    },
                    {
                        text = _("Fullscreen"),
                        checked_func = function() return isRatioMode("fullscreen") end,
                        callback = function()
                            G_reader_settings:saveSetting(CARD_RATIO_MODE_SETTING, "fullscreen")
                        end,
                        radio = true,
                    },
                    {
                        text = _("Custom ratio"),
                        checked_func = function() return isRatioMode("custom") end,
                        callback = function()
                            G_reader_settings:saveSetting(CARD_RATIO_MODE_SETTING, "custom")
                            local cur_val = G_reader_settings:readSetting(CARD_RATIO_CUSTOM_SETTING) or "0.60"
                            local input_dialog
                            input_dialog = InputDialog:new{
                                title = _("Custom card ratio (0.30 - 1.00)\ne.g. 0.65 for 65% screen width"),
                                input = tostring(cur_val),
                                input_type = "number",
                                buttons = {
                                    {
                                        {
                                            text = _("Cancel"),
                                            id = "close",
                                            callback = function()
                                                UIManager:close(input_dialog)
                                            end,
                                        },
                                        {
                                            text = _("Set"),
                                            is_enter_default = true,
                                            callback = function()
                                                local input_text = input_dialog:getInputText()
                                                input_text = input_text:gsub(",", ".")
                                                local num = tonumber(input_text)
                                                if num then
                                                    if num > 1 then num = num / 100 end
                                                    num = math.max(0.30, math.min(1.00, num))
                                                    G_reader_settings:saveSetting(CARD_RATIO_CUSTOM_SETTING, num)
                                                    UIManager:close(input_dialog)
                                                end
                                            end,
                                        },
                                    },
                                },
                            }
                            UIManager:show(input_dialog)
                            input_dialog:onShowKeyboard()
                        end,
                        radio = true,
                    },
                },
            }

            local function isBorderSetting(val)
                local cur = G_reader_settings:readSetting(BOOK_RECEIPT_BORDER_SETTING) or "none"
                return cur == val
            end

            local function isCardBgSetting(val)
                local cur = G_reader_settings:readSetting(BOOK_RECEIPT_CARD_BG_SETTING) or "light_gray"
                return cur == val
            end

            local border_sub_menu = {
                text = _("Card border"),
                sub_item_table = {
                    {
                        text = _("No border"),
                        checked_func = function() return isBorderSetting("none") end,
                        callback = function() G_reader_settings:saveSetting(BOOK_RECEIPT_BORDER_SETTING, "none") end,
                        radio = true,
                    },
                    {
                        text = _("Thin border"),
                        checked_func = function() return isBorderSetting("thin") end,
                        callback = function() G_reader_settings:saveSetting(BOOK_RECEIPT_BORDER_SETTING, "thin") end,
                        radio = true,
                    },
                    {
                        text = _("Thick border"),
                        checked_func = function() return isBorderSetting("thick") end,
                        callback = function() G_reader_settings:saveSetting(BOOK_RECEIPT_BORDER_SETTING, "thick") end,
                        radio = true,
                    },
                },
            }

            local bg_color_sub_menu = {
                text = _("Card background color"),
                sub_item_table = {
                    {
                        text = _("Light gray (default)"),
                        checked_func = function() return isCardBgSetting("light_gray") end,
                        callback = function() G_reader_settings:saveSetting(BOOK_RECEIPT_CARD_BG_SETTING, "light_gray") end,
                        radio = true,
                    },
                    {
                        text = _("Pure white"),
                        checked_func = function() return isCardBgSetting("pure_white") end,
                        callback = function() G_reader_settings:saveSetting(BOOK_RECEIPT_CARD_BG_SETTING, "pure_white") end,
                        radio = true,
                    },
                    {
                        text = _("Soft gray"),
                        checked_func = function() return isCardBgSetting("soft_gray") end,
                        callback = function() G_reader_settings:saveSetting(BOOK_RECEIPT_CARD_BG_SETTING, "soft_gray") end,
                        radio = true,
                    },
                },
            }

            local appearance_menu = {
                text = _("Card appearance"),
                sub_item_table = {
                    border_sub_menu,
                    bg_color_sub_menu,
                    {
                        text = _("Card drop shadow"),
                        checked_func = function()
                            return G_reader_settings:isTrue(BOOK_RECEIPT_SHADOW_SETTING)
                        end,
                        callback = function()
                            local cur = G_reader_settings:isTrue(BOOK_RECEIPT_SHADOW_SETTING)
                            G_reader_settings:saveSetting(BOOK_RECEIPT_SHADOW_SETTING, not cur)
                        end,
                    },
                },
            }

            local function toggleMenuItem(text, setting)
                return {
                    text = text,
                    checked_func = function()
                        return G_reader_settings:nilOrTrue(setting)
                    end,
                    callback = function()
                        G_reader_settings:flipNilOrTrue(setting)
                    end,
                }
            end

            local display_items_menu = {
                text = _("Display items"),
                sub_item_table = {
                    toggleMenuItem(_("Book title"), SHOW_ITEM_TITLE_SETTING),
                    toggleMenuItem(_("Author"), SHOW_ITEM_AUTHOR_SETTING),
                    toggleMenuItem(_("Cover"), SHOW_ITEM_COVER_SETTING),
                    toggleMenuItem(_("Current chapter"), SHOW_ITEM_CHAPTER_SETTING),
                    toggleMenuItem(_("Page count"), SHOW_ITEM_PAGE_NUMBER_SETTING),
                    toggleMenuItem(_("Reading percentage"), SHOW_ITEM_PERCENTAGE_SETTING),
                    toggleMenuItem(_("Progress bar"), SHOW_ITEM_PROGRESS_BAR_SETTING),
                    toggleMenuItem(_("Chapter time left"), SHOW_ITEM_CHAPTER_TIME_LEFT_SETTING),
                    toggleMenuItem(_("Book time left"), SHOW_ITEM_BOOK_TIME_LEFT_SETTING),
                    toggleMenuItem(_("Total time spent"), SHOW_ITEM_TOTAL_TIME_SETTING),
                    toggleMenuItem(_("Time spent today"), SHOW_ITEM_TODAY_TIME_SETTING),
                    toggleMenuItem(_("Battery level"), SHOW_ITEM_BATTERY_SETTING),
                    toggleMenuItem(_("Current time"), SHOW_ITEM_CLOCK_SETTING),
                    toggleMenuItem(_("Highlights & annotations"), SHOW_ITEM_HIGHLIGHTS_SETTING),
                    toggleMenuItem(_("Custom screensaver message"), SHOW_ITEM_CUSTOM_MESSAGE_SETTING),
                },
            }

            table.insert(wallpaper_submenu, 7, {
                text = _("Book receipt settings"),
                enabled_func = isBookReceiptEnabled,
                sub_item_table = {
                    style_menu,
                    ratio_menu,
                    appearance_menu,
                    background_menu,
                    display_items_menu,
                },
            })
        end
    end

    return result
end
