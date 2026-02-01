;;; init-browser.el --- Browser settings -*- lexical-binding: t -*-

;;; Commentary:
;;  逻辑说明：
;;  1. 入口 my/browse-url 接收 URL。
;;  2. 第一层判断：当前 Emacs 是否支持 xwidget？
;;     - 不支持 -> 直接调用系统浏览器 (browse-url-default-browser)。
;;     - 支持   -> 进入第二层判断。
;;  3. 第二层判断 (仅在支持 xwidget 时)：URL 是否"复杂"？
;;     - 复杂 (视频/JS重站) -> 使用 xwidget-webkit。
;;     - 简单 (文档/博客)   -> 使用 EWW。

;;; Code:

;;;; 1. xwidget-webkit 基础配置 (仅在支持时加载)

(when (featurep 'xwidget-internal)
  ;; xwidget buffer 名字更清晰
  (setq xwidget-webkit-buffer-name-format "*xwidget: %t*")

  (with-eval-after-load 'xwidget
    (define-key xwidget-webkit-mode-map (kbd "q") #'quit-window)
    (define-key xwidget-webkit-mode-map (kbd "g") #'xwidget-webkit-reload)
    (define-key xwidget-webkit-mode-map (kbd "l") #'xwidget-webkit-browse-url)
    (define-key xwidget-webkit-mode-map (kbd "b") #'xwidget-webkit-back)
    (define-key xwidget-webkit-mode-map (kbd "f") #'xwidget-webkit-forward)
    (define-key xwidget-webkit-mode-map (kbd "y") #'xwidget-webkit-copy-selection-as-kill)

    (when (fboundp 'xwidget-webkit-current-url)
      (define-key xwidget-webkit-mode-map (kbd "Y")
        (lambda ()
          (interactive)
          (kill-new (xwidget-webkit-current-url))
          (message "Copied URL."))))))

;;;; 2. 智能分流逻辑

(defun my/url-looks-complex-p (url)
  "Heuristic: 判断 URL 是否可能需要 JS/复杂渲染。"
  (let ((u (downcase url)))
    (or (string-match-p
         (regexp-opt
          '("youtube.com" "bilibili.com" "github.com" "gitlab.com"
            "notion.so" "figma.com" "docs.google.com" "drive.google.com"
            "openai.com" "chatgpt.com" "accounts.google.com"
            "cloudflare" "login" "signin" "oauth" "sso"
            "stripe.com" "paypal.com" "twitter.com" "x.com")
          t)
         u)
        ;; URL 里带很多 query 参数也往往更复杂
        (> (length (or (url-filename (url-generic-parse-url u)) "")) 80))))

(defun my/browse-url (url &optional _new-window)
  "统一浏览入口：
   1. 无 xwidget 支持 -> 系统浏览器。
   2. 有 xwidget 支持 -> 复杂网战用 xwidget，简单用 EWW。"
  (interactive (browse-url-interactive-arg "URL: "))
  ;; 确保 URL 带有协议头
  (unless (string-match-p "\\`https?://" url)
    (setq url (concat "https://" url)))

  ;; --- 核心逻辑修改处 ---
  (if (featurep 'xwidget-internal)
      ;; 分支 A: 具备 xwidget 能力，进行 EWW/Webkit 分流
      (if (my/url-looks-complex-p url)
          (xwidget-webkit-browse-url url) ;; 复杂 -> Webkit
        (eww-browse-url url))             ;; 简单 -> EWW
    
    ;; 分支 B: 不具备 xwidget 能力，全部走系统浏览器
    (browse-url-default-browser url)))

;; 设置默认浏览器函数
(setq browse-url-browser-function #'my/browse-url)

;;;; 3. 按键绑定

(global-set-key (kbd "C-c w e") #'eww-browse-url) ;; 强制 EWW
(global-set-key (kbd "C-c w w") #'browse-url)     ;; 智能分发

;; 仅当有 xwidget 支持时，才绑定强制 xwidget 的快捷键，防止报错
(when (featurep 'xwidget-internal)
  (global-set-key (kbd "C-c w x") #'xwidget-webkit-browse-url))

;; EWW 配置
(with-eval-after-load 'eww
  (setq eww-search-prefix "https://duckduckgo.com/?q=")
  (define-key eww-mode-map (kbd "R") #'eww-readable))

;;;; 4. EWW <-> Xwidget 互转 (带安全检查)

(defun my/eww-get-url ()
  (if (derived-mode-p 'eww-mode) (plist-get eww-data :url) nil))

(defun my/xwidget-get-url ()
  (if (and (featurep 'xwidget-internal)
           (eq major-mode 'xwidget-webkit-mode))
      (xwidget-webkit-uri (xwidget-webkit-current-session))
    nil))

(defun my/eww-to-xwidget ()
  "从 EWW 切换到 Xwidget (仅当支持 xwidget 时有效)"
  (interactive)
  (if (not (featurep 'xwidget-internal))
      (message "当前 Emacs 版本不支持 Xwidget，无法切换。")
    (let ((url (my/eww-get-url))
          (old-buf (current-buffer)))
      (if url
          (progn
            (message "Switching to Xwidget: %s" url)
            (xwidget-webkit-browse-url url)
            (run-at-time "0 sec" nil 
                         (lambda (b) (when (buffer-live-p b) (kill-buffer b))) 
                         old-buf))
        (message "无法获取 URL")))))

(defun my/xwidget-to-eww ()
  "从 Xwidget 切换到 EWW"
  (interactive)
  (let ((url (my/xwidget-get-url))
        (old-buf (current-buffer)))
    (if url
        (progn
          (message "Switching to EWW: %s" url)
          (eww url)
          (run-at-time "0 sec" nil 
                       (lambda (b) (when (buffer-live-p b) (kill-buffer b))) 
                       old-buf))
      (message "无法获取 URL"))))

(provide 'init-browser)
;;; init-browser.el ends here
