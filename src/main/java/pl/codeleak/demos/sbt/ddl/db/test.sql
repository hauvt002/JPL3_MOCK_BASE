create or replace NONEDITIONABLE PACKAGE BODY                     PKG_OS_TCKH AS

    -------------------------------------------------
    -- Func gen mã nhiệm vụ
    FUNCTION FN_GEN_MA_NHIEMVU_SEL(p_nhanvien_id NUMBER,
        p_phanvung_id IN NUMBER) RETURN VARCHAR2 AS
    v_manhiemvu VARCHAR2(50);
    v_tiento VARCHAR2(50);
    v_maxid VARCHAR2(10);
BEGIN
BEGIN
            --dbms_output.put_line(p_nhanvien_id);
SELECT distinct dv.tiento
INTO v_tiento
FROM admin.donvi dv LEFT JOIN admin.nhanvien nv ON nv.donvi_id = dv.donvi_id
WHERE nv.nhanvien_id = p_nhanvien_id AND nv.PHANVUNG_ID = p_phanvung_id;

dbms_output.put_line(v_tiento);
SELECT LPAD((SELECT MAX(lantao_id) + 1 FROM taodl_tc), 6, '0')
INTO v_maxid
FROM dual;

--dbms_output.put_line(v_maxid);
IF v_maxid IS NOT NULL THEN
                v_manhiemvu    := v_tiento || '-TC' || v_maxid;
ELSE
                v_manhiemvu    := v_tiento || '-TC000001';
END IF;
            --dbms_output.put_line(v_manhiemvu);

EXCEPTION
          WHEN no_data_found THEN
            v_manhiemvu := '';
END;
RETURN  TRIM(v_manhiemvu);

END FN_GEN_MA_NHIEMVU_SEL;


   -------------------------------------------------
    -- Func lấy danh sách dịch vụ
    FUNCTION FN_GET_DS_DICHVU_SEL (
      p_dichvu_code IN VARCHAR2,
      p_dichvu_name IN VARCHAR2)
    RETURN SYS_REFCURSOR IS
         l_result      SYS_REFCURSOR;
         l_sql      VARCHAR2(20000);
BEGIN
        --Lay thong tin danh sach dich vu
BEGIN
              l_sql := 'select  DICHVUVT_ID AS dichVuvtId, MA_DVVT AS maDvvt, TEN_DVVT AS tenDvvt from dichvu_vt where 1=1 and SUDUNG = 1 ';

              IF p_dichvu_code IS NOT NULL THEN
                l_sql :=  l_sql|| ' and MA_DVVT = '''
                          || p_dichvu_code ||'''';
END IF;

              IF p_dichvu_name IS NOT NULL THEN
                l_sql := l_sql
                        || ' and lower(TEN_DVVT) like ''%'
                        ||lower(p_dichvu_name)
                        || '%''';
END IF;
              dbms_output.put_line(l_sql);
OPEN l_result FOR l_sql;
RETURN l_result;

EXCEPTION
            WHEN OTHERS THEN
BEGIN

                    --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                         || sqlerrm
                                         || ')'' name from dual';

RETURN l_result;
END;
END;
END;

    --------------------------------------------
    -- Func lấy danh sách nhân viên tiếp cận
    FUNCTION FN_GET_DS_NHANVIEN_TC_SEL (
        p_donvi_id IN NUMBER,
        p_phan_vung_id IN NUMBER)
    RETURN SYS_REFCURSOR IS
        l_result      SYS_REFCURSOR;
BEGIN
    --Lay thong tin danh sach nhan vien
BEGIN
OPEN l_result FOR
SELECT  nv.NHANVIEN_ID, nv.TEN_NV,nv.SO_DT, nv.EMAIL
FROM admin.NHANVIEN nv
         INNER JOIN admin.NHANVIEN_LNV nvlvn ON nv.NHANVIEN_ID = nvlvn.NHANVIEN_ID
WHERE nv.DONVI_ID = p_donvi_id
  and nvlvn.LOAINV_ID = 104
  and nv.PHANVUNG_ID = p_phan_vung_id;
RETURN l_result;

EXCEPTION
              WHEN OTHERS THEN
BEGIN

                    --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                        || sqlerrm
                                        || ')'' name from dual';

RETURN l_result;
END;
END;
END;

    ----------------------------------------------------------------
    -- Proc Thêm mới nhiệm vụ
    PROCEDURE SP_TAO_MOI_NHIEMVU(l_result            	OUT SYS_REFCURSOR,
							   p_loainv_id    			IN NUMBER,
                               p_manv                   IN VARCHAR2,
							   p_donvi_nhan_id   		IN NUMBER,
							   p_nhanvien_nhan_id       IN NUMBER,
							   p_ngay_giao  			IN DATE,
							   p_nhanvien_id 			IN NUMBER,
							   p_donvi_id 				IN NUMBER,
							   p_ngay_th 				IN DATE,
							   p_dichvuvt_id 			IN NUMBER,
							   p_loaitb_id 				IN NUMBER,
							   p_noi_dung 				IN VARCHAR2,
							   p_trang_thai 			IN NUMBER,
							   p_ngay_cn 				IN DATE,
							   p_nguoi_cn 				IN VARCHAR2,
							   p_may_cn 				IN VARCHAR2,
							   p_ip_cn 					IN VARCHAR2,
                               p_ma_khach_hang          IN VARCHAR2,
							   p_phanvung_id    		IN NUMBER) IS
        n 			NUMBER;
        l_lantao_id NUMBER;
        l_khachhang_check NUMBER;
        l_khachhang_nv_check NUMBER;
BEGIN
        --dbms_output.put_line(p_manv);
        l_lantao_id := SEQ_TAODL_TC.nextval;

INSERT INTO TAODL_TC
(LANTAO_ID,
 MA_NV,
 LOAINV_ID,
 DONVI_NHAN_ID,
 NHANVIEN_NHAN_ID,
 NGAY_GIAO,
 NHANVIEN_ID,
 DONVI_ID,
 NGAY_TH,
 DICHVUVT_ID,
 LOAITB_ID,
 NOIDUNG,
 TRANGTHAI,
 NGAY_CN,
 NGUOI_CN,
 MAY_CN,
 IP_CN,
 PHANVUNG_ID
)
VALUES
    (l_lantao_id,
     p_manv,
     p_loainv_id,
     p_donvi_nhan_id,
     p_nhanvien_nhan_id,
     p_ngay_giao,
     p_nhanvien_id,
     p_donvi_id,
     p_ngay_th,
     p_dichvuvt_id,
     p_loaitb_id,
     p_noi_dung,
     p_trang_thai,
     p_ngay_cn,
     p_nguoi_cn,
     p_may_cn,
     p_ip_cn,
     p_phanvung_id
    );

--dbms_output.put_line(l_ma_nv);
IF p_ma_khach_hang IS NOT NULL THEN
            FOR l_ma_khach_hang IN (
                SELECT value
                FROM
                  (SELECT regexp_substr (p_ma_khach_hang, '[^,]+', 1, LEVEL) value
                   FROM dual CONNECT BY LEVEL <= LENGTH (p_ma_khach_hang) - LENGTH
                     (REPLACE (p_ma_khach_hang,',')) + 1))
            LOOP
                --dbms_output.put_line(l_ma_khach_hang.value);

SELECT count(khachhang_id) INTO l_khachhang_check
FROM db_khachhang
WHERE khachhang_id = l_ma_khach_hang.value AND PHANVUNG_ID = p_phanvung_id;

SELECT count(khachhang_id) INTO l_khachhang_nv_check
FROM TAODL_TCKH
WHERE khachhang_id = l_ma_khach_hang.value AND LANTAO_ID = l_lantao_id AND PHANVUNG_ID = p_phanvung_id;

IF l_khachhang_check > 0 AND l_khachhang_nv_check = 0 THEN
                    INSERT INTO TAODL_TCKH
                        (LANTAO_ID,
                         KHACHHANG_ID,
                         NGAY_CN,
                         NGUOI_CN,
                         MAY_CN,
                         IP_CN,
                         PHANVUNG_ID
                         )
                    VALUES
                        (l_lantao_id,
                        l_ma_khach_hang.value,
                        p_ngay_cn,
                        p_nguoi_cn,
                        p_may_cn,
                        p_ip_cn,
                        p_phanvung_id
                        );
END IF;
                --dbms_output.put_line(l_ma_khach_hang.value);
END LOOP;
END IF;

        n := SQL%ROWCOUNT;
        --dbms_output.put_line(n);

OPEN l_result FOR
SELECT n AS ketqua FROM dual;

COMMIT;

EXCEPTION
          WHEN OTHERS THEN
BEGIN
                --dbms_output.put_line('k1');
OPEN l_result FOR
SELECT 0 AS ketqua FROM dual;
END;

END SP_TAO_MOI_NHIEMVU;


 ----------------------------------------------------------------
    -- Proc cập nhật nhiệm vụ
    PROCEDURE SP_CAP_NHAT_NHIEMVU(l_result            	OUT SYS_REFCURSOR,
                               p_lantao_id              IN NUMBER,
                               p_manv                   IN VARCHAR2,
							   p_loainv_id    			IN NUMBER,
							   p_donvi_nhan_id   		IN NUMBER,
							   p_nhanvien_nhan_id       IN NUMBER,
							   p_ngay_giao  			IN DATE,
							   p_nhanvien_id 			IN NUMBER,
							   p_donvi_id 				IN NUMBER,
							   p_ngay_th 				IN DATE,
							   p_dichvuvt_id 			IN NUMBER,
							   p_loaitb_id 				IN NUMBER,
							   p_noi_dung 				IN VARCHAR2,
							   p_trang_thai 			IN NUMBER,
							   p_ngay_cn 				IN DATE,
							   p_nguoi_cn 				IN VARCHAR2,
							   p_may_cn 				IN VARCHAR2,
							   p_ip_cn 					IN VARCHAR2,
                               p_ma_khach_hang          IN VARCHAR2,
							   p_phanvung_id    		IN NUMBER) IS
	n 			NUMBER;
    l_khachhang_check NUMBER;
    l_khachhang_nv_check NUMBER;
BEGIN

UPDATE TAODL_TC
SET LOAINV_ID       = p_loainv_id,
    DONVI_ID        = p_donvi_id,
    NHANVIEN_ID     = p_nhanvien_id,
    NGAY_GIAO       = p_ngay_giao,
    NGAY_TH         = p_ngay_th,
    DICHVUVT_ID     = p_dichvuvt_id,
    LOAITB_ID       = p_loaitb_id,
    NOIDUNG         = p_noi_dung,
    DONVI_NHAN_ID   = p_donvi_nhan_id,
    NHANVIEN_NHAN_ID= p_nhanvien_nhan_id
WHERE LANTAO_ID = p_lantao_id AND PHANVUNG_ID = p_phanvung_id;

IF p_ma_khach_hang IS NOT NULL THEN

DELETE FROM TAODL_TCKH WHERE LANTAO_ID = p_lantao_id AND PHANVUNG_ID = p_phanvung_id;

FOR l_ma_khach_hang IN (
                SELECT value
                FROM
                  (SELECT regexp_substr (p_ma_khach_hang, '[^,]+', 1, LEVEL) value
                   FROM dual CONNECT BY LEVEL <= LENGTH (p_ma_khach_hang) - LENGTH
                     (REPLACE (p_ma_khach_hang,',')) + 1))
            LOOP
                --dbms_output.put_line(l_ma_khach_hang.value);

SELECT count(khachhang_id) INTO l_khachhang_check
FROM db_khachhang
WHERE khachhang_id = l_ma_khach_hang.value AND PHANVUNG_ID = p_phanvung_id;

SELECT count(khachhang_id) INTO l_khachhang_nv_check
FROM TAODL_TCKH
WHERE khachhang_id = l_ma_khach_hang.value AND LANTAO_ID = p_lantao_id AND PHANVUNG_ID = p_phanvung_id;

IF l_khachhang_check > 0 AND l_khachhang_nv_check = 0 THEN
                    INSERT INTO TAODL_TCKH
                        (LANTAO_ID,
                         KHACHHANG_ID,
                         NGAY_CN,
                         NGUOI_CN,
                         MAY_CN,
                         IP_CN,
                         PHANVUNG_ID
                         )
                    VALUES
                        (p_lantao_id,
                        l_ma_khach_hang.value,
                        p_ngay_cn,
                        p_nguoi_cn,
                        p_may_cn,
                        p_ip_cn,
                        p_phanvung_id
                        );
END IF;
                --dbms_output.put_line(l_ma_khach_hang.value);
END LOOP;
END IF;

        n := SQL%ROWCOUNT;
        --dbms_output.put_line(n);

OPEN l_result FOR
SELECT n AS ketqua FROM dual;

COMMIT;

EXCEPTION
          WHEN OTHERS THEN
BEGIN
                --dbms_output.put_line('k1');
OPEN l_result FOR
SELECT 0 AS ketqua FROM dual;
END;

END SP_CAP_NHAT_NHIEMVU;

--------------------------------------------------
    -- Func Xóa nhiệm vụ
    FUNCTION FN_XOA_NHIEMVU_CHK(
        p_nhiemvu_id_lst IN varchar,
		p_phanvung_id IN NUMBER)
        return VARCHAR2
        IS
        l_result VARCHAR2(4000);
        l_count_record NUMBER(1);
        l_nhiemvu_id_check VARCHAR2(2000);
        l_sql VARCHAR2(4000);
BEGIN
BEGIN
SAVEPOINT update_bar;
dbms_output.put_line(p_nhiemvu_id_lst);
FOR rec IN (
                SELECT value
                FROM
                  (SELECT regexp_substr (p_nhiemvu_id_lst, '[^,]+', 1, LEVEL) value
                   FROM dual CONNECT BY LEVEL <= LENGTH (p_nhiemvu_id_lst) - LENGTH
                     (REPLACE (p_nhiemvu_id_lst,',')) + 1))
             LOOP
SELECT count(lantao_id) INTO l_count_record
FROM taodl_tc
WHERE lantao_id = rec.value AND trangthai = 1 AND PHANVUNG_ID = p_phanvung_id;

IF l_count_record >0 THEN
                    l_nhiemvu_id_check :=l_nhiemvu_id_check || ',' || rec.value;
END IF;
END LOOP;
            l_nhiemvu_id_check := RTRIM(SUBSTR(l_nhiemvu_id_check,2,LENGTH(l_nhiemvu_id_check) ));
            dbms_output.put_line(l_nhiemvu_id_check);
        IF p_nhiemvu_id_lst = l_nhiemvu_id_check THEN
DELETE FROM taodl_tc WHERE lantao_id IN ( SELECT value
                                          FROM
                                              (SELECT regexp_substr (p_nhiemvu_id_lst, '[^,]+', 1, LEVEL) value
                                               FROM dual CONNECT BY LEVEL <= LENGTH (p_nhiemvu_id_lst) - LENGTH
                                                                  (REPLACE (p_nhiemvu_id_lst,',')) + 1) x) AND PHANVUNG_ID = p_phanvung_id;
l_result := 'TRUE';
ELSE
            l_nhiemvu_id_check := REPLACE(p_nhiemvu_id_lst,l_nhiemvu_id_check,'');
            l_nhiemvu_id_check := RTRIM(SUBSTR(l_nhiemvu_id_check,2,LENGTH(l_nhiemvu_id_check) ));
            l_result := 'Các nhiệm vụ có id sau : ' || l_nhiemvu_id_check ||' không tồn tại trong hệ thống! vui lòng kiểm tra lại';
END IF;

EXCEPTION
                WHEN OTHERS THEN
BEGIN
ROLLBACK TO update_bar;
--ulog.plog.error(vc_tmp);
l_result := 'FALSE';
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END FN_XOA_NHIEMVU_CHK;

--------------------------------------------------
    -- Func Xóa Kế Hoạch
   FUNCTION FN_XOA_KEHOACH_CHK(
        p_tiepcan_id_lst IN varchar,
		p_phanvung_id IN NUMBER)
        return VARCHAR2
        IS
        l_result VARCHAR2(4000);
        l_count_record NUMBER(1);
        l_tiepcan_id_check VARCHAR2(2000);
        l_ma_kh VARCHAR2(2000);
        l_sql VARCHAR2(4000);
BEGIN
BEGIN
SAVEPOINT update_bar;
--dbms_output.put_line(p_tiepcan_id_lst);
FOR rec IN (
                SELECT value
                FROM
                  (SELECT regexp_substr (p_tiepcan_id_lst, '[^,]+', 1, LEVEL) value
                   FROM dual CONNECT BY LEVEL <= LENGTH (p_tiepcan_id_lst) - LENGTH
                     (REPLACE (p_tiepcan_id_lst,',')) + 1))
             LOOP
                --dbms_output.put_line(rec.value);
SELECT count(tiepcan_id) INTO l_count_record
FROM tiepcan_kh
WHERE tiepcan_id = rec.value AND trangthaitc_id IN (1,2) AND PHANVUNG_ID = p_phanvung_id;

--dbms_output.put_line(l_count_record);
IF l_count_record >0 THEN
                    l_tiepcan_id_check :=l_tiepcan_id_check || ',' || rec.value;
END IF;
END LOOP;
            l_tiepcan_id_check := RTRIM(SUBSTR(l_tiepcan_id_check,2,LENGTH(l_tiepcan_id_check) ));
            --dbms_output.put_line(l_tiepcan_id_check);
        IF p_tiepcan_id_lst = l_tiepcan_id_check THEN
DELETE FROM css.tiepcan_kh WHERE tiepcan_id IN ( SELECT value
                                                 FROM
                                                     (SELECT regexp_substr (p_tiepcan_id_lst, '[^,]+', 1, LEVEL) value
                                                      FROM dual CONNECT BY LEVEL <= LENGTH (p_tiepcan_id_lst) - LENGTH
                                                                         (REPLACE (p_tiepcan_id_lst,',')) + 1) x) AND PHANVUNG_ID = p_phanvung_id;
l_result := 'SUCCESS';
ELSE
            l_tiepcan_id_check := REPLACE(p_tiepcan_id_lst,l_tiepcan_id_check,'');
            --dbms_output.put_line(l_tiepcan_id_check);
            l_tiepcan_id_check := RTRIM(SUBSTR(l_tiepcan_id_check,1,LENGTH(l_tiepcan_id_check) ));

FOR abc in (select ma_kh from tiepcan_kh WHERE PHANVUNG_ID = p_phanvung_id AND tiepcan_id IN ( SELECT value
                FROM
                  (SELECT regexp_substr (p_tiepcan_id_lst, '[^,]+', 1, LEVEL) value
                   FROM dual CONNECT BY LEVEL <= LENGTH (p_tiepcan_id_lst) - LENGTH
                     (REPLACE (p_tiepcan_id_lst,',')) + 1) x))
            LOOP l_ma_kh := l_ma_kh || ', ' || abc.ma_kh;
END LOOP;
            l_ma_kh := RTRIM(SUBSTR(l_ma_kh,2,LENGTH(l_ma_kh) ));
            l_result := 'Các mã kế hoạch sau : ' || l_ma_kh ||' không hợp lệ! vui lòng kiểm tra lại';
END IF;

EXCEPTION
                WHEN OTHERS THEN
BEGIN
ROLLBACK TO update_bar;
--ulog.plog.error(vc_tmp);
l_result := 'Co Loi xay ra ' ||sqlerrm;
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END FN_XOA_KEHOACH_CHK;


FUNCTION FN_APPROVAL_KHTC_CHK(
	p_tiep_can_id_lst   IN VARCHAR,
    p_phanvung_id       IN NUMBER)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_id_tiepcan VARCHAR2(2000);
    l_ma_kh VARCHAR2(2000);
BEGIN
BEGIN
SAVEPOINT ABC;
--get danh sach id tiep can
FOR rec IN (
            SELECT value
            FROM
              (SELECT regexp_substr (p_tiep_can_id_lst, '[^,]+', 1, LEVEL) value
               FROM dual CONNECT BY LEVEL <= LENGTH (p_tiep_can_id_lst) - LENGTH
                 (REPLACE (p_tiep_can_id_lst,',')) + 1) x
            WHERE NOT EXISTS
                (SELECT tiepcan_kh.tiepcan_id
                 FROM tiepcan_kh
                 WHERE tiepcan_kh.tiepcan_id = x.value
                 AND TIEPCAN_KH.trangthaitc_id IN (1,2) AND TIEPCAN_KH.PHANVUNG_ID = p_phanvung_id)
                 )
         LOOP
              l_id_tiepcan :=l_id_tiepcan || ',' || rec.value;

END LOOP;
        l_id_tiepcan :=  RTRIM(SUBSTR(l_id_tiepcan,2,LENGTH(l_id_tiepcan) )); --loai bo dau , o dau tien

        IF l_id_tiepcan IS NULL THEN

UPDATE css.TIEPCAN_KH
SET TIEPCAN_KH.trangthaitc_id = 3
WHERE PHANVUNG_ID = p_phanvung_id AND tiepcan_kh.tiepcan_id IN (SELECT value FROM
    (SELECT regexp_substr (p_tiep_can_id_lst, '[^,]+', 1, LEVEL) value FROM dual
     CONNECT BY LEVEL <= LENGTH (p_tiep_can_id_lst) - LENGTH (REPLACE (p_tiep_can_id_lst,',')) + 1) x);
l_result := 'TRUE';
ELSE
         FOR abc in (select ma_kh from tiepcan_kh WHERE PHANVUNG_ID = p_phanvung_id AND tiepcan_id IN ( SELECT value
                FROM
                  (SELECT regexp_substr (p_tiep_can_id_lst, '[^,]+', 1, LEVEL) value
                   FROM dual CONNECT BY LEVEL <= LENGTH (p_tiep_can_id_lst) - LENGTH
                     (REPLACE (p_tiep_can_id_lst,',')) + 1) x))
            LOOP l_ma_kh := l_ma_kh || ', ' || abc.ma_kh;
END LOOP;
            l_ma_kh := RTRIM(SUBSTR(l_ma_kh,2,LENGTH(l_ma_kh) ));
            l_result := 'Các mã kế hoạch sau : ' || l_ma_kh ||' không hợp lệ! vui lòng kiểm tra lại';
END IF;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
--                    l_result := 'FALSE';
l_result := 'Co Loi xay ra ' ||sqlerrm;
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;

FUNCTION FN_PHE_DUYET_KHTC_CHK(
	p_tiep_can_id IN NUMBER,
    p_noi_dung_duyet IN VARCHAR2,
    p_phanvung_id IN NUMBER)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_tiep_can_id NUMBER;
BEGIN
BEGIN
SAVEPOINT ABC;

SELECT COUNT(1) INTO l_tiep_can_id
FROM TIEPCAN_KH
WHERE TIEPCAN_KH.tiepcan_id = p_tiep_can_id AND TIEPCAN_KH.trangthaitc_id = 3 AND PHANVUNG_ID = p_phanvung_id;

dbms_output.put_line(l_tiep_can_id);
    IF l_tiep_can_id > 0 THEN
UPDATE css.TIEPCAN_KH
SET TIEPCAN_KH.trangthaitc_id = 5 ,
    TIEPCAN_KH.noidung_duyet = p_noi_dung_duyet
WHERE tiepcan_id = p_tiep_can_id AND PHANVUNG_ID = p_phanvung_id;
l_result := 'TRUE';
ELSE
        l_result := 'Kế hoạch có id sau : ' || p_tiep_can_id ||' không tồn tại trong hệ thống hoặc kiểm tra lại trạng thái!';
END IF;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
l_result := 'FALSE';
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;
------------------------------
FUNCTION FN_TRA_LAI_KHTC_CHK(
		p_tiep_can_id IN NUMBER,
        p_noi_dung_duyet IN VARCHAR2,
		p_phanvung_id IN NUMBER)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_tiep_can_id NUMBER;
BEGIN
BEGIN
SAVEPOINT ABC;

SELECT COUNT(1) INTO l_tiep_can_id
FROM TIEPCAN_KH
WHERE TIEPCAN_KH.tiepcan_id = p_tiep_can_id AND TIEPCAN_KH.trangthaitc_id = 3 AND PHANVUNG_ID = p_phanvung_id;

dbms_output.put_line(l_tiep_can_id);
    IF l_tiep_can_id > 0 THEN
UPDATE TIEPCAN_KH
SET TIEPCAN_KH.trangthaitc_id = (
    SELECT
        CASE
            WHEN LANTAO_ID IS NULL THEN 2
            WHEN LANTAO_ID IS NOT NULL THEN 1 END AS StatusText
    FROM TIEPCAN_KH
    WHERE tiepcan_id = p_tiep_can_id),
    TIEPCAN_KH.noidung_duyet = p_noi_dung_duyet
WHERE tiepcan_id = p_tiep_can_id AND PHANVUNG_ID = p_phanvung_id;
l_result := 'TRUE';
ELSE
        l_result := 'Kế hoạch có id sau : ' || p_tiep_can_id ||' không tồn tại trong hệ thống hoặc kiểm tra lại trạng thái!';
END IF;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
l_result := 'FALSE';
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;
    -------------------------------------------------
    -- Func lấy thông tin kế hoạch TC
    FUNCTION FN_GET_THONGTIN_KEHOACH_TC_SEL (p_loai_nhiem_vu          IN VARCHAR2,
                                   p_ten_chuong_trinh       IN VARCHAR2,
                                   p_tu_ngay                IN DATE,
                                   p_den_ngay               IN DATE,
                                   p_nhiemvu_khachhang_lst  IN VARCHAR2,
                                   p_nhan_vien_id           IN NUMBER,
                                   p_phanvung_id IN NUMBER)
         RETURN SYS_REFCURSOR IS
         l_loai_nv_id NUMBER;
         l_result      SYS_REFCURSOR;
         l_sql      VARCHAR2(20000);
         l_nhiemvu_khachhang_lst      VARCHAR2(20000);
BEGIN
BEGIN
        -- -------p_loai_chuong_trinh = 'CTBH'
    IF p_loai_nhiem_vu = 'CTBH' THEN
        l_sql := 'SELECT TO_CHAR(tk.NGAY_TC, ''DD/MM/YYYY'') ngayTiepCan,';
        l_sql := l_sql || 'taodl_tc.MA_NV maNhiemVu,';
        l_sql := l_sql || 'kh.MA_KH maKhachHang,';
        l_sql := l_sql || 'kh.TEN_KH tenKhachHang,';
        l_sql := l_sql || 'kh.DIACHI_KH diaChiKhachHang,';
        l_sql := l_sql || 'tk.NGUOI_LH nguoiLienHe,';
        l_sql := l_sql || 'tk.SDT_LH soDienThoaiLienHe,';
        l_sql := l_sql || 'tk.EMAIL_LH emailLienHe,';
        l_sql := l_sql || 'tk.HINHTHUC htTiepCan,';
        l_sql := l_sql || 'dichvu_vt.TEN_DVVT tenDichVu,';
        l_sql := l_sql || 'loaihinh_tb.LOAIHINH_TB tenLoaiHinh,';
        l_sql := l_sql || 'vat_pham.TEN_VAT_PHAM vatPhamCS,';
        l_sql := l_sql || 'tk.NOIDUNG noiDungTC ';


        l_sql := l_sql || ' from ctbh_temp ct
                            join TIEPCAN_KH tk on ct.ma_ct=tk.MA_CT ';

        l_sql := l_sql || 'LEFT JOIN taodl_tc ON taodl_tc.LANTAO_ID = tk.LANTAO_ID ';
        l_sql := l_sql || 'INNER JOIN taodl_tckh ON taodl_tc.LANTAO_ID = taodl_tckh.LANTAO_ID ';
        l_sql := l_sql || 'INNER JOIN db_khachhang kh ON kh.KHACHHANG_ID = taodl_tckh.KHACHHANG_ID ';
        l_sql := l_sql || 'LEFT JOIN dichvu_vt ON taodl_tc.DICHVUVT_ID = dichvu_vt.DICHVUVT_ID ';
        l_sql := l_sql || 'LEFT JOIN loaihinh_tb ON taodl_tc.LOAITB_ID = loaihinh_tb.LOAITB_ID ';
        l_sql := l_sql || 'LEFT JOIN vat_pham_tckh ON tk.TIEPCAN_ID = vat_pham_tckh.TIEPCAN_ID ';
        l_sql := l_sql || 'LEFT JOIN vat_pham ON vat_pham.VAT_PHAM_ID = vat_pham_tckh.VATPHAM_ID ';
        l_sql := l_sql || 'WHERE 1 = 1 and kh.KHACHHANG_ID = tk.KHACHHANG_ID AND ct.loai_ct = ''CTBH'' ';

        IF p_nhan_vien_id IS NOT NULL THEN
             l_sql := l_sql || ' AND tk.NHANVIEN_ID = ' || p_nhan_vien_id;
END IF;

        IF p_tu_ngay IS NOT NULL THEN
            l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

        IF p_den_ngay IS NOT NULL THEN
            l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

        IF p_ten_chuong_trinh IS NOT NULL THEN
        l_sql := l_sql || ' and ct.ten_ct LIKE ''%' || p_ten_chuong_trinh || '%''';
END IF;

         l_sql := l_sql || ' and tk.phanvung_id  = ' || p_phanvung_id;
         l_sql := l_sql || ' and taodl_tc.phanvung_id  = ' || p_phanvung_id;
         l_sql := l_sql || ' and taodl_tckh.phanvung_id  = ' || p_phanvung_id;
         l_sql := l_sql || ' and kh.phanvung_id  = ' || p_phanvung_id;

         l_sql := l_sql || ' ORDER BY tk.ngay_cn DESC';
END IF;

    -----------p_loai_chuong_trinh = 'CTCSKH'

    IF p_loai_nhiem_vu = 'CTCSKH' THEN
        l_sql := 'SELECT TO_CHAR(tk.NGAY_TC, ''DD/MM/YYYY'') ngayTiepCan,';
        l_sql := l_sql || 'taodl_tc.MA_NV maNhiemVu,';
        l_sql := l_sql || 'kh.MA_KH maKhachHang,';
        l_sql := l_sql || 'kh.TEN_KH tenKhachHang,';
        l_sql := l_sql || 'kh.DIACHI_KH diaChiKhachHang,';
        l_sql := l_sql || 'tk.NGUOI_LH nguoiLienHe,';
        l_sql := l_sql || 'tk.SDT_LH soDienThoaiLienHe,';
        l_sql := l_sql || 'tk.EMAIL_LH emailLienHe,';
        l_sql := l_sql || 'tk.HINHTHUC htTiepCan,';
        l_sql := l_sql || 'dichvu_vt.TEN_DVVT tenDichVu,';
        l_sql := l_sql || 'loaihinh_tb.LOAIHINH_TB tenLoaiHinh,';
        l_sql := l_sql || 'vat_pham.TEN_VAT_PHAM vatPhamCS,';
        l_sql := l_sql || 'tk.NOIDUNG noiDungTC ';

        l_sql := l_sql || ' from CTCSKH_temp ct
                 join TIEPCAN_KH tk on ct.ma_ct=tk.MA_CT ';

        l_sql := l_sql || 'LEFT JOIN taodl_tc ON taodl_tc.LANTAO_ID = tk.LANTAO_ID ';
        l_sql := l_sql || 'INNER JOIN taodl_tckh ON taodl_tc.LANTAO_ID = taodl_tckh.LANTAO_ID ';
        l_sql := l_sql || 'INNER JOIN db_khachhang kh ON kh.KHACHHANG_ID = taodl_tckh.KHACHHANG_ID ';
        l_sql := l_sql || 'LEFT JOIN dichvu_vt ON taodl_tc.DICHVUVT_ID = dichvu_vt.DICHVUVT_ID ';
        l_sql := l_sql || 'LEFT JOIN loaihinh_tb ON taodl_tc.LOAITB_ID = loaihinh_tb.LOAITB_ID ';
        l_sql := l_sql || 'LEFT JOIN vat_pham_tckh ON tk.TIEPCAN_ID = vat_pham_tckh.TIEPCAN_ID ';
        l_sql := l_sql || 'LEFT JOIN vat_pham ON vat_pham.VAT_PHAM_ID = vat_pham_tckh.VATPHAM_ID ';
        l_sql := l_sql || 'WHERE 1 = 1 and kh.KHACHHANG_ID = tk.KHACHHANG_ID AND ct.loai_ct = ''CTCSKH'' ';

        IF p_nhan_vien_id IS NOT NULL THEN
             l_sql := l_sql || ' AND tk.NHANVIEN_ID = ' || p_nhan_vien_id;
END IF;

        IF p_tu_ngay IS NOT NULL THEN
        l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

        IF p_den_ngay IS NOT NULL THEN
            l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

        IF p_ten_chuong_trinh IS NOT NULL THEN
        l_sql := l_sql || ' and ct.ten_ct LIKE ''%' || p_ten_chuong_trinh || '%''';
END IF;

         l_sql := l_sql || ' and tk.phanvung_id  = ' || p_phanvung_id;
         l_sql := l_sql || ' and taodl_tc.phanvung_id  = ' || p_phanvung_id;
         l_sql := l_sql || ' and taodl_tckh.phanvung_id  = ' || p_phanvung_id;
         l_sql := l_sql || ' and kh.phanvung_id  = ' || p_phanvung_id;

        l_sql := l_sql || ' ORDER BY tk.ngay_cn DESC';
END IF;
   -----------   p_loai_chuong_trinh = 'KHTN'


    IF p_loai_nhiem_vu = 'KHTN' THEN
        l_sql := 'SELECT TO_CHAR(tiepcan_kh.NGAY_TC, ''DD/MM/YYYY'') ngayTiepCan,';
        l_sql := l_sql || 'taodl_tc.MA_NV maNhiemVu,';
        l_sql := l_sql || 'kh.MA_KH maKhachHang,';
        l_sql := l_sql || 'kh.TEN_KH tenKhachHang,';
        l_sql := l_sql || 'kh.DIACHI_KH diaChiKhachHang,';
        l_sql := l_sql || 'tiepcan_kh.NGUOI_LH nguoiLienHe,';
        l_sql := l_sql || 'tiepcan_kh.SDT_LH soDienThoaiLienHe,';
        l_sql := l_sql || 'tiepcan_kh.EMAIL_LH emailLienHe,';
        l_sql := l_sql || 'tiepcan_kh.HINHTHUC htTiepCan,';
        l_sql := l_sql || 'dichvu_vt.TEN_DVVT tenDichVu,';
        l_sql := l_sql || 'loaihinh_tb.LOAIHINH_TB tenLoaiHinh,';
        l_sql := l_sql || 'vat_pham.TEN_VAT_PHAM vatPhamCS,';
        l_sql := l_sql || 'tiepcan_kh.NOIDUNG noiDungTC ';

        l_sql := l_sql || 'FROM tiepcan_kh ';
        l_sql := l_sql || 'LEFT JOIN taodl_tc ON taodl_tc.LANTAO_ID = tiepcan_kh.LANTAO_ID ';
        l_sql := l_sql || 'INNER JOIN taodl_tckh ON taodl_tc.LANTAO_ID = taodl_tckh.LANTAO_ID ';
        l_sql := l_sql || 'INNER JOIN db_khachhang kh ON kh.KHACHHANG_ID = taodl_tckh.KHACHHANG_ID ';
        l_sql := l_sql || 'LEFT JOIN dichvu_vt ON taodl_tc.DICHVUVT_ID = dichvu_vt.DICHVUVT_ID ';
        l_sql := l_sql || 'LEFT JOIN loaihinh_tb ON taodl_tc.LOAITB_ID = loaihinh_tb.LOAITB_ID ';
        l_sql := l_sql || 'LEFT JOIN vat_pham_tckh ON tiepcan_kh.TIEPCAN_ID = vat_pham_tckh.TIEPCAN_ID ';
        l_sql := l_sql || 'LEFT JOIN vat_pham ON vat_pham.VAT_PHAM_ID = vat_pham_tckh.VATPHAM_ID ';
        l_sql := l_sql || 'WHERE 1 = 1 and kh.KHACHHANG_ID = tiepcan_kh.KHACHHANG_ID ';

        IF p_tu_ngay IS NOT NULL THEN
            l_sql := l_sql || ' AND TO_DATE(tiepcan_kh.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

        IF p_den_ngay IS NOT NULL THEN
            l_sql := l_sql || ' AND TO_DATE(tiepcan_kh.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

        IF p_nhiemvu_khachhang_lst IS NOT NULL THEN
            FOR rec IN (
                SELECT value
                FROM
                    (SELECT regexp_substr (p_nhiemvu_khachhang_lst, '[^,]+', 1, LEVEL) value
                FROM dual CONNECT BY LEVEL <= LENGTH (p_nhiemvu_khachhang_lst) - LENGTH
                    (REPLACE (p_nhiemvu_khachhang_lst,',')) + 1))
            LOOP
                l_nhiemvu_khachhang_lst := l_nhiemvu_khachhang_lst || '''' || rec.value || ''',';
END LOOP;
            l_nhiemvu_khachhang_lst := RTRIM(SUBSTR(l_nhiemvu_khachhang_lst, 0, LENGTH(l_nhiemvu_khachhang_lst) -1));
            -- dbms_output.put_line(l_nhiemvu_khachhang_lst);
            l_sql := l_sql || ' AND taodl_tc.MA_NV ' || '|| ''@''' || '|| kh.ma_kh  IN (' || l_nhiemvu_khachhang_lst || ')';

END IF;

         l_sql := l_sql || ' and tiepcan_kh.phanvung_id  = ' || p_phanvung_id;
         l_sql := l_sql || ' and taodl_tc.phanvung_id  = ' || p_phanvung_id;
         l_sql := l_sql || ' and taodl_tckh.phanvung_id  = ' || p_phanvung_id;
         l_sql := l_sql || ' and kh.phanvung_id  = ' || p_phanvung_id;

        l_sql := l_sql || ' ORDER BY tiepcan_kh.ngay_cn DESC';
END IF;
            dbms_output.put_line(l_sql);
OPEN l_result FOR l_sql;
RETURN l_result;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
OPEN l_result FOR 'select ''Co Lo xay ra('
                                         || sqlerrm
                                         || ')'' name from dual';
RETURN l_result;
END;
END;
END FN_GET_THONGTIN_KEHOACH_TC_SEL;

--------------------------------------------------------
FUNCTION FN_HOAN_THANH_KHTC_CHK(
	p_tiep_can_id IN NUMBER,
     p_phanvung_id   IN NUMBER)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_id_tc NUMBER;
    l_id_nv NUMBER;
BEGIN
BEGIN
SAVEPOINT update_stt;

SELECT COUNT(1)INTO l_id_tc
FROM TIEPCAN_KH tckh
WHERE tckh.tiepcan_id = p_tiep_can_id AND tckh.trangthaitc_id = 5 and tckh.phanvung_id = p_phanvung_id ;


IF l_id_tc > 0 THEN
SELECT COUNT(1) INTO l_id_nv
FROM TIEPCAN_KH tckh
WHERE tckh.tiepcan_id = p_tiep_can_id
  AND tckh.phanvung_id = p_phanvung_id
  AND tckh.lantao_id IS NOT NULL;

IF l_id_nv > 0 THEN

UPDATE taodl_tc SET TRANGTHAI = 3 WHERE LANTAO_ID = (SELECT tckh.lantao_id
                                                     FROM TIEPCAN_KH tckh
                                                     WHERE tckh.tiepcan_id = p_tiep_can_id
                                                       AND tckh.lantao_id IS NOT NULL and tckh.phanvung_id = p_phanvung_id) and taodl_tc.phanvung_id = p_phanvung_id; --update hoan thanh bang nhiem vu
UPDATE tiepcan_kh SET TRANGTHAITC_ID = 6 WHERE TIEPCAN_ID = p_tiep_can_id and tiepcan_kh.phanvung_id = p_phanvung_id; --update hoan thanh  bang tiepcan

ELSE

UPDATE tiepcan_kh SET TRANGTHAITC_ID = 6 WHERE TIEPCAN_ID = p_tiep_can_id and tiepcan_kh.phanvung_id = p_phanvung_id; --update hoan thanh  bang tiepcan
END IF;
            l_result := 'TRUE';
ELSE
            l_result := 'Kế hoạch có id sau : ' || p_tiep_can_id ||' không tồn tại trong hệ thống hoặc kiểm tra lại trạng thái!';
END IF;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO update_stt;
--ulog.plog.error(vc_tmp);
l_result := 'FALSE';
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;

--------------------------

-- Lấy danh sách nhiệm vụ tiếp cận
PROCEDURE SP_GET_DS_NHIEMVU_TIEPCAN_LIST(
  p_nhanvien_id IN NUMBER,
  p_trang_thai_id_lst IN VARCHAR,
  p_pn_page_id IN NUMBER,
  p_pn_rec_per_page IN NUMBER,
  p_phanvung_id IN NUMBER,
  v_cusor     OUT SYS_REFCURSOR,
  v_total     OUT number
  )
is
     l_result   SYS_REFCURSOR;
     l_sql      VARCHAR2(20000);
     l_countTotal number:=0;
BEGIN
    --Lay thong tin danh sach
    l_sql := 'SELECT tckh.MA_KH maKeHoach,
            tdltc.LOAINV_ID loaiNhiemVuId,
            tckh.NGAY_TC ngayTiepCan,
            tckh.HINHTHUC hinhThuc,
            kh.MA_KH maKhachHang,
            kh.TEN_KH tenKhachHang,
            dvvt.TEN_DVVT tenDichVuVT,
            lhtb.LOAIHINH_TB tenLoaiHinhTb,
            tckh.LANTAO_ID nhiemVuId,
            tckh.TIEPCAN_ID tiepCanKHId,
            tckh.NOIDUNG noiDung,
            tckh.KHACHHANG_ID khachHangId,
            tckh.NOIDUNG_DUYET noiDungDuyet,
            tdltc.MA_NV maNhiemVu,
            tttckh.TRANGTHAITC_ID trangThaiTCId,
            tttckh.TRANGTHAI_TCKH trangThaiTCName,
            tckh.DICHVUVT_ID dichVuId,
            tckh.LOAITB_ID loaiHinhId,
            tckh.KETQUATC_ID ketQuaId,
            tckh.DOANHTHU_TANG doanhThuTang,
            tckh.DOANHTHU_GIAM doanhThuGiam,
            tckh.DEXUAT deXuat,
            tckh.TT_DOITHU thongTinDoiThu,
            tckh.NGUOI_LH nguoiTC,
            tckh.SDT_LH sdtNguoiTC,
            tckh.EMAIL_LH emailNguoiTC,
            tckh.CHUCVU_LH chucvuNguoiTC,
            tckh.MA_CT maChuongTrinh,
            kh.mst maSoThue,
            kh.SO_GT soGiayTo,
            kh.DIACHI_KH diaChiKhachHang,
            tdltc.NGAY_GIAO ngayGiao';
    l_sql := l_sql || ' FROM css.TIEPCAN_KH tckh ';
    l_sql := l_sql || ' LEFT JOIN css.TAODL_TC tdltc ON (tdltc.LANTAO_ID = tckh.LANTAO_ID AND tdltc.phanvung_id = tckh.phanvung_id)';
    l_sql := l_sql || ' INNER JOIN css.DB_KHACHHANG kh ON (kh.KHACHHANG_ID = tckh.KHACHHANG_ID AND kh.phanvung_id = tckh.phanvung_id)';
    l_sql := l_sql || ' LEFT JOIN css.DICHVU_VT dvvt ON dvvt.DICHVUVT_ID = tckh.DICHVUVT_ID ';
    l_sql := l_sql || ' LEFT JOIN css.LOAIHINH_TB lhtb ON lhtb.LOAITB_ID = tckh.LOAITB_ID ';
    l_sql := l_sql || ' INNER JOIN css.TRANGTHAI_TCKH tttckh ON tttckh.TRANGTHAITC_ID = tckh.TRANGTHAITC_ID ';


        IF(p_nhanvien_id IS NULL) THEN
                OPEN l_result FOR 'select ''Khong duoc de trong p_nhan_vien_id'' name from dual';

END IF;

        --case la luong tao truc tiep thi lay theo tiepcan_kh.nhanvien_id
        --else la luong tao truc tiep thi lay theo tiepcan_kh.nhanvien_id)
        l_sql := l_sql || ' WHERE (case when tckh.LANTAO_ID is null then tckh.NHANVIEN_ID else tdltc.nhanvien_id end )  = ' ||  p_nhanvien_id;

        IF(p_trang_thai_id_lst IS NULL) THEN
                OPEN l_result FOR 'select ''Khong duoc de trong p_trang_thai_id'' name from dual';
END IF;

        l_sql := l_sql || ' AND tckh.TRANGTHAITC_ID IN (' ||  p_trang_thai_id_lst || ') ';

        l_sql := l_sql || ' AND tckh.phanvung_id = ' ||  p_phanvung_id;

        l_sql := l_sql || ' ORDER BY tckh.ngay_cn desc';

        --lay count data truoc khi qua phan trang
        dbms_output.put_line(v_total);
        v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);

        --lay data cusor sau phan trang
        dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN
                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';
v_total := 0;
                v_cusor := l_result;

END;
END;

    --Lấy chi tiết vật phẩm
PROCEDURE SP_GET_CT_VATPHAM_CSKH ( p_id IN NUMBER,
                                       l_ma_vat_pham  OUT  VARCHAR2,
                                       l_ten_vat_pham OUT  VARCHAR2 )
IS
BEGIN
        IF p_id <> 0 THEN
SELECT vt.MA_VAT_PHAM, vt.TEN_VAT_PHAM
INTO l_ma_vat_pham, l_ten_vat_pham
FROM css.VAT_PHAM vt
WHERE vt.VAT_PHAM_ID = p_id;
END IF;

EXCEPTION
          WHEN OTHERS THEN
BEGIN
                --dbms_output.put_line('k1');
                l_ma_vat_pham := null;
                l_ten_vat_pham := null;
END;
END;

-- lấy danh sách vật phẩm
FUNCTION FN_GET_DS_VATPHAM_CSKH_SEL (p_id_ke_hoach IN NUMBER,
  p_phan_vung_id IN NUMBER)
RETURN SYS_REFCURSOR IS
     l_result      SYS_REFCURSOR;
BEGIN
    if(p_id_ke_hoach is null) then
                OPEN l_result FOR 'select ''Khong duoc de trong p_ma_ke_hoach'' name from dual';
RETURN l_result;
end if;

OPEN l_result FOR
SELECT vt.VAT_PHAM_ID idVatPham, vt.MA_VAT_PHAM maVatPham, vt.TEN_VAT_PHAM tenVatPham
FROM css.VAT_PHAM vt
         INNER JOIN css.VAT_PHAM_TCKH vptckh
                    ON vt.VAT_PHAM_ID = vptckh.VATPHAM_ID
         INNER JOIN css.TIEPCAN_KH tckh
                    ON tckh.TIEPCAN_ID = vptckh.TIEPCAN_ID
WHERE tckh.TIEPCAN_ID = p_id_ke_hoach and tckh.PHANVUNG_ID = p_phan_vung_id;

RETURN l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN

                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';

RETURN l_result;
END;
END FN_GET_DS_VatPham_CSKH_SEL;
-------------------------------
PROCEDURE SP_GET_DS_NHIEMVU_LIST(
  p_nhanvien_id IN NUMBER,
  p_type_get IN NUMBER,
  p_pn_page_id IN NUMBER,
  p_pn_rec_per_page IN NUMBER,
  p_phanvung_id IN NUMBER,
  v_cusor     OUT SYS_REFCURSOR,
  v_total     OUT number
  )
is
     l_result   SYS_REFCURSOR;
     l_sql      VARCHAR2(20000);
     l_countTotal number:=0;
BEGIN
     --Lay thong tin danh sach dich vu
    l_sql := 'select taodl_tc.NGAY_GIAO AS ngayGiao,
    taodl_tc.NGAY_TH AS ngayTh,
    taodl_tc.MA_NV AS maNv,
    nhanvien.ten_nv AS tenNv,
    nhanvien.so_dt AS soDt,
    dichvu_vt.TEN_DVVT AS tenDvvt,
    loaihinh_tb.LOAIHINH_TB AS loaiHinhTb,
    taodl_tc.trangthai AS trangThai,
    taodl_tc.lantao_id AS lanTaoId,
    taodl_tc.DONVI_NHAN_ID AS donViId,
    taodl_tc.loainv_id AS loaiNvId,
    taodl_tc.nhanvien_nhan_id AS nhanVienNhanId,
    taodl_tc.dichvuvt_id AS dichVuVtId,
    taodl_tc.loaitb_id AS loaiTbId,
    taodl_tc.noidung AS noiDung,
    taodl_tc.ngay_cn AS ngayTao,
    TRANGTHAI_KH.TRANGTHAI_KH trangThaiName,
    LISTAGG( taodl_tckh.khachhang_id, '', '' ) WITHIN GROUP( ORDER BY taodl_tckh.khachhang_id ) AS khachHangId ';
    l_sql := l_sql || ' from taodl_tc ';
    l_sql := l_sql || ' LEFT JOIN dichvu_vt ON taodl_tc.DICHVUVT_ID = dichvu_vt.DICHVUVT_ID ';
    l_sql := l_sql || ' LEFT JOIN loaihinh_tb ON taodl_tc.LOAITB_ID = loaihinh_tb.LOAITB_ID ';
    l_sql := l_sql || ' LEFT JOIN taodl_tckh ON (taodl_tckh.lantao_id = taodl_tc.lantao_id AND taodl_tckh.phanvung_id = taodl_tc.phanvung_id)';
    l_sql := l_sql || ' INNER JOIN TRANGTHAI_KH ON TRANGTHAI_KH.TTKH_ID = taodl_tc.trangthai ';

--        IF p_type_get = 1 THEN
            l_sql := l_sql || ' JOIN admin.nhanvien ON taodl_tc.NHANVIEN_NHAN_ID = nhanvien.NHANVIEN_ID ' ;
            l_sql := l_sql || ' where taodl_tc.NHANVIEN_ID = ' ||  p_nhanvien_id;
--        END IF;

        IF p_type_get = 2 THEN
--          l_sql := l_sql || 'JOIN admin.nhanvien ON taodl_tc.NHANVIEN_NHAN_ID = nhanvien.NHANVIEN_ID ' ;
--            l_sql := l_sql || 'where nhanvien.NHANVIEN_ID = ' ||  p_nhanvien_id;
            l_sql := l_sql || ' AND taodl_tc.trangthai = 2 ' ;
END IF;

        l_sql := l_sql || ' AND taodl_tc.phanvung_id = ' || p_phanvung_id ;

        l_sql := l_sql || ' GROUP BY
                            taodl_tc.NGAY_GIAO,
                            taodl_tc.NGAY_TH,
                            taodl_tc.MA_NV,
                            nhanvien.ten_nv,
                            nhanvien.so_dt,
                            dichvu_vt.TEN_DVVT,
                            loaihinh_tb.LOAIHINH_TB,
                            taodl_tc.trangthai,
                            taodl_tc.lantao_id,
                            taodl_tc.DONVI_NHAN_ID,
                            taodl_tc.loainv_id,
                            taodl_tc.nhanvien_nhan_id,
                            taodl_tc.dichvuvt_id,
                            taodl_tc.loaitb_id,
                            taodl_tc.noidung,
                            taodl_tc.ngay_cn,
                            TRANGTHAI_KH.TRANGTHAI_KH ';
        IF p_type_get = 2 THEN
            l_sql := l_sql || ' ORDER BY taodl_tc.NGAY_GIAO desc ';
ELSE
        l_sql := l_sql || ' ORDER BY taodl_tc.ngay_cn desc ';
END IF;

        --lay count data truoc khi qua phan trang
        dbms_output.put_line(v_total);
        v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);

        --lay data cusor sau phan trang
        dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN
                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';
v_total := 0;
                v_cusor := l_result;

END;
END;
-------------------------------------------------
-------------------------------------------------
FUNCTION FN_GIAO_NHIEMVU_TCKH_CHK(
	p_nhiemvu_id_lst IN VARCHAR,
    p_phanvung_id IN NUMBER)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_id_nhiemvu VARCHAR2(2000);
    l_sql VARCHAR2(4000);
BEGIN
BEGIN
SAVEPOINT update_stt;
--get danh sach id tiep can
FOR rec IN (
        SELECT value
        FROM
          (SELECT regexp_substr (p_nhiemvu_id_lst, '[^,]+', 1, LEVEL) value
           FROM dual CONNECT BY LEVEL <= LENGTH (p_nhiemvu_id_lst) - LENGTH
             (REPLACE (p_nhiemvu_id_lst,',')) + 1) x
        WHERE NOT EXISTS
            (SELECT lantao_id
             FROM taodl_tc
             WHERE taodl_tc.lantao_id = x.value AND taodl_tc.trangthai = 1
             and taodl_tc.phanvung_id = p_phanvung_id)
             )
     LOOP
          l_id_nhiemvu :=l_id_nhiemvu || ',' || rec.value;

END LOOP;
    l_id_nhiemvu :=  RTRIM(SUBSTR(l_id_nhiemvu,2,LENGTH(l_id_nhiemvu) )); --loai bo dau , o dau tien

    IF l_id_nhiemvu IS NULL THEN
UPDATE taodl_tc
SET taodl_tc.trangthai = 2
WHERE taodl_tc.lantao_id IN (SELECT value FROM
    (SELECT regexp_substr (p_nhiemvu_id_lst, '[^,]+', 1, LEVEL) value FROM dual
     CONNECT BY LEVEL <= LENGTH (p_nhiemvu_id_lst) - LENGTH (REPLACE (p_nhiemvu_id_lst,',')) + 1) x)
  and taodl_tc.phanvung_id = p_phanvung_id;
l_result := 'TRUE';
ELSE
        l_result := 'Các nhiệm vụ có id sau : ' || l_id_nhiemvu ||' không tồn tại trong hệ thống hoặc kiểm tra lại trạng thái!';
END IF;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO update_stt;
--ulog.plog.error(vc_tmp);
l_result := 'FALSE';
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;
----------------------------------------------------------
PROCEDURE SP_CREATE_TIEPCAN_KH_INS(l_result            	OUT SYS_REFCURSOR,
							   p_tiep_can_id   			    NUMBER,
							   p_ma_ke_hoach  		        VARCHAR2,
							   p_id_nhiem_vu                VARCHAR2,
							   p_loai_nhiem_vu  			VARCHAR2,
							   p_khach_hang_id			    NUMBER,
							   p_hinh_thuc			        NUMBER,
							   p_ngay_tiep_can 				DATE,
							   p_dichvuvt_id 			    VARCHAR2,
							   p_loaitb_id 				    VARCHAR2,
							   p_noi_dung 				    VARCHAR2,
							   p_vp_cskh_id 				VARCHAR2,
							   p_nhanvien_id				NUMBER,
							   p_trang_thai_tc_id			NUMBER,
							   p_donvi_duyet_id				NUMBER,
							   p_ngay_cn					DATE,
							   p_nguoi_cn					VARCHAR2,
							   p_may_cn						VARCHAR2,
							   p_ip_cn						VARCHAR2,
							   p_phanvung_id				NUMBER,
                               p_ma_chuong_tring            VARCHAR2,
                               p_nguoi_tc                   VARCHAR2,
                               p_sdt_nguoi_tc               VARCHAR2,
                               p_email_nguoi_tc             VARCHAR2,
                               p_chuc_vu_nguoi_tc           VARCHAR2,
                               p_ten_ct                     VARCHAR2
							   )
IS
	n 			NUMBER;
    l_tiep_can_id NUMBER;
BEGIN

SAVEPOINT ABC;

INSERT INTO TIEPCAN_KH
(
    TIEPCAN_ID,
    MA_KH,
    LANTAO_ID,
    KHACHHANG_ID,
    HINHTHUC,
    NGAY_TC,
    NHANVIEN_ID,
    DICHVUVT_ID,
    LOAITB_ID,
    NOIDUNG,
    TRANGTHAITC_ID,
    DONVI_DUYET_ID,
    NOIDUNG_DUYET,
    NOIDUNG_TC,
    KETQUATC_ID,
    DOANHTHU_TANG,
    DOANHTHU_GIAM,
    TT_DOITHU,
    DEXUAT,
    NGAY_CN,
    NGUOI_CN,
    MAY_CN,
    IP_CN,
    PHANVUNG_ID,
    NGUOI_LH,
    SDT_LH,
    EMAIL_LH,
    CHUCVU_LH,
    MA_CT
)
VALUES
    (SEQ_TIEPCAN_KH.nextval,
     p_ma_ke_hoach,
     CASE WHEN p_id_nhiem_vu IS NOT NULL THEN TO_NUMBER(p_id_nhiem_vu, '9999999999') ELSE NULL END,
     p_khach_hang_id,
     p_hinh_thuc,
     p_ngay_tiep_can,
     p_nhanvien_id,
     CASE WHEN p_dichvuvt_id IS NOT NULL THEN TO_NUMBER(p_dichvuvt_id, '99999') ELSE NULL END,
     CASE WHEN p_loaitb_id IS NOT NULL THEN TO_NUMBER(p_loaitb_id, '99999') ELSE NULL END,
     p_noi_dung,
     p_trang_thai_tc_id,
     p_donvi_duyet_id,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     p_ngay_cn,
     p_nguoi_cn,
     p_may_cn,
     p_ip_cn,
     p_phanvung_id,
     p_nguoi_tc,
     p_sdt_nguoi_tc,
     p_email_nguoi_tc,
     p_chuc_vu_nguoi_tc,
     p_ma_ke_hoach
    );
SELECT max(TIEPCAN_ID) INTO l_tiep_can_id from TIEPCAN_KH;
IF p_id_nhiem_vu IS NOT NULL AND p_loai_nhiem_vu IS NOT NULL THEN
UPDATE TAODL_TC
SET LOAINV_ID           = TO_NUMBER(p_loai_nhiem_vu, '9')
WHERE LANTAO_ID 		= TO_NUMBER(p_id_nhiem_vu, '9999999999') AND PHANVUNG_ID = p_phanvung_id;
END IF;

IF p_vp_cskh_id IS NOT NULL THEN
           FOR l_vp_cskh_id IN (
                SELECT value
                FROM
                  (SELECT regexp_substr (p_vp_cskh_id, '[^,]+', 1, LEVEL) value
                   FROM dual CONNECT BY LEVEL <= LENGTH (p_vp_cskh_id) - LENGTH
                     (REPLACE (p_vp_cskh_id,',')) + 1))
			LOOP
DELETE FROM VAT_PHAM_TCKH WHERE VATPHAM_ID = l_vp_cskh_id.value;
--dbms_output.put_line(l_vp_cskh_id.value);
INSERT INTO VAT_PHAM_TCKH
(TIEPCAN_ID,
 VATPHAM_ID,
 NGAY_CN,
 NGUOI_CN,
 MAY_CN,
 IP_CN
)
VALUES
    (l_tiep_can_id,
     l_vp_cskh_id.value,
     p_ngay_cn,
     p_nguoi_cn,
     p_may_cn,
     p_ip_cn
    );
--dbms_output.put_line(l_ma_khach_hang.value);
END LOOP;
END IF;

n := SQL%ROWCOUNT;
        --dbms_output.put_line(n);

OPEN l_result FOR
SELECT n AS ketqua FROM dual;

COMMIT;

EXCEPTION
        WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--dbms_output.put_line('k1');
OPEN l_result FOR
SELECT 0 AS ketqua FROM dual;
END;
END;
----------------------------------------------------
PROCEDURE SP_UPDATE_TIEPCAN_KH_UPD(l_result            	OUT SYS_REFCURSOR,
							   p_tiep_can_id   			    NUMBER,
							   p_ma_ke_hoach  		        VARCHAR2,
							   p_id_nhiem_vu                VARCHAR2,
							   p_loai_nhiem_vu  			VARCHAR2,
							   p_khach_hang_id			    NUMBER,
                               p_phanvung_id			    NUMBER,
                               p_trang_thai_tc_id		    NUMBER,
							   p_hinh_thuc			        NUMBER,
							   p_ngay_tiep_can 				DATE,
							   p_dichvuvt_id 			    VARCHAR2,
							   p_loaitb_id 				    VARCHAR2,
							   p_noi_dung 				    VARCHAR2,
							   p_vp_cskh_id 				VARCHAR2,
                               p_ngay_cn					DATE,
							   p_nguoi_cn					VARCHAR2,
							   p_may_cn						VARCHAR2,
							   p_ip_cn						VARCHAR2,
                               p_ma_chuong_tring            VARCHAR2,
                               p_nguoi_tc                   VARCHAR2,
                               p_sdt_nguoi_tc               VARCHAR2,
                               p_email_nguoi_tc             VARCHAR2,
                               p_chuc_vu_nguoi_tc           VARCHAR2,
                               p_ten_ct                     VARCHAR2)
IS
	n 			NUMBER;
BEGIN
SAVEPOINT ABC;
UPDATE css.TIEPCAN_KH
SET MA_KH           = p_ma_ke_hoach,
    LANTAO_ID       = CASE WHEN p_id_nhiem_vu IS NOT NULL THEN TO_NUMBER(p_id_nhiem_vu, '9999999999') ELSE NULL END,
    KHACHHANG_ID    = p_khach_hang_id,
    HINHTHUC        = p_hinh_thuc,
    NGAY_TC         = p_ngay_tiep_can,
    DICHVUVT_ID     = CASE WHEN p_dichvuvt_id IS NOT NULL THEN TO_NUMBER(p_dichvuvt_id, '9999999999') ELSE NULL END,
    LOAITB_ID       = CASE WHEN p_loaitb_id IS NOT NULL THEN TO_NUMBER(p_loaitb_id, '9999999999') ELSE NULL END,
    NOIDUNG         = p_noi_dung,
    TRANGTHAITC_ID  = p_trang_thai_tc_id,
    NGUOI_LH        = p_nguoi_tc,
    SDT_LH          = p_sdt_nguoi_tc,
    EMAIL_LH        = p_email_nguoi_tc,
    CHUCVU_LH       = p_chuc_vu_nguoi_tc,
    MA_CT           = p_ma_ke_hoach,
    NGAY_CN         = p_ngay_cn
WHERE TIEPCAN_ID = p_tiep_can_id AND PHANVUNG_ID = p_phanvung_id;

IF p_id_nhiem_vu IS NOT NULL AND p_loai_nhiem_vu IS NOT NULL THEN
UPDATE TAODL_TC
SET LOAINV_ID           = TO_NUMBER(p_loai_nhiem_vu, '9')
WHERE LANTAO_ID 		= TO_NUMBER(p_id_nhiem_vu, '9999999999') and phanvung_id = p_phanvung_id;
END IF;

        IF p_vp_cskh_id IS NOT NULL THEN
                   FOR l_vp_cskh_id IN (
                        SELECT value
                        FROM
                          (SELECT regexp_substr (p_vp_cskh_id, '[^,]+', 1, LEVEL) value
                           FROM dual CONNECT BY LEVEL <= LENGTH (p_vp_cskh_id) - LENGTH
                             (REPLACE (p_vp_cskh_id,',')) + 1))
                    LOOP
DELETE FROM VAT_PHAM_TCKH WHERE VATPHAM_ID = l_vp_cskh_id.value;
--dbms_output.put_line(l_vp_cskh_id.value);
INSERT INTO VAT_PHAM_TCKH
(TIEPCAN_ID,
 VATPHAM_ID,
 NGAY_CN,
 NGUOI_CN,
 MAY_CN,
 IP_CN
)
VALUES
    (p_tiep_can_id,
     l_vp_cskh_id.value,
     p_ngay_cn,
     p_nguoi_cn,
     p_may_cn,
     p_ip_cn
    );
--dbms_output.put_line(l_ma_khach_hang.value);
END LOOP;
END IF;

n := SQL%ROWCOUNT;
        --dbms_output.put_line(n);

OPEN l_result FOR
SELECT n AS ketqua FROM dual;

COMMIT;

EXCEPTION
          WHEN OTHERS THEN
BEGIN

ROLLBACK TO ABC;                 --dbms_output.put_line('k1');
OPEN l_result FOR
SELECT 0 AS ketqua FROM dual;
END;
END;
-------------------------------------------------------

-------------------------------------------------
    -- Func gen mã kế hoạch
    FUNCTION FN_GEN_MA_KEHOACH_SEL RETURN VARCHAR2 AS
    l_ma_kehoach VARCHAR2(50);
    l_maxid VARCHAR2(10);
BEGIN
BEGIN
SELECT LPAD((SELECT MAX(TIEPCAN_ID) + 1 FROM tiepcan_kh), 6, '0')
INTO l_maxid
FROM dual;

--dbms_output.put_line(l_maxid);
IF l_maxid IS NOT NULL THEN
                l_ma_kehoach    := 'KH' || l_maxid;
ELSE
                l_ma_kehoach    := 'KH000001';
END IF;
            --dbms_output.put_line(l_ma_kehoach);

EXCEPTION
          WHEN no_data_found THEN
            l_ma_kehoach := '';
END;
RETURN TRIM(l_ma_kehoach);

END FN_GEN_MA_KEHOACH_SEL;

-----------------------------------------------------------
    --Update ket qua
FUNCTION FN_UPDATE_KETQUA_THKH_CHK(
	p_tiep_can_id IN NUMBER,
    p_ketqua_id IN NUMBER,
    p_doanhthu_tang IN NUMBER,
    p_doanhthu_giam IN NUMBER,
    p_dexuat IN VARCHAR,
    p_tt_doi_thu IN VARCHAR,
    p_ngay_cn IN DATE,
    p_nguoi_cn IN VARCHAR,
	p_phanvung_id IN NUMBER)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_count_id NUMBER;
    l_count_ketqua_id NUMBER;
BEGIN
BEGIN
SAVEPOINT KETQUA_THKH;
-- Check p_tiep_can_id có tồn tài
SELECT COUNT(1) INTO l_count_id
FROM css.TIEPCAN_KH tckh
WHERE tckh.TIEPCAN_ID = p_tiep_can_id AND tckh.PHANVUNG_ID = p_phanvung_id;

dbms_output.put_line(l_count_id);
            IF l_count_id <> 0 THEN
            -- Check p_ketqua_id có tồn tại trong KETQUA_TCKH hay không
SELECT count(1) INTO l_count_ketqua_id
FROM css.KETQUA_TCKH kqtckh
WHERE kqtckh.KETQUATC_ID = p_ketqua_id;

IF l_count_ketqua_id <> 0 THEN
UPDATE TIEPCAN_KH
SET KETQUATC_ID     =    p_ketqua_id,
    DOANHTHU_TANG   =    p_doanhthu_tang,
    DOANHTHU_GIAM   =    p_doanhthu_giam,
    DEXUAT          =    p_dexuat,
    TT_DOITHU       =    p_tt_doi_thu,
    NGAY_CN         =    p_ngay_cn,
    NGUOI_CN        =    p_nguoi_cn
WHERE TIEPCAN_ID = p_tiep_can_id AND PHANVUNG_ID = p_phanvung_id;
l_result := 'TRUE';
ELSE
                l_result := 'INVALID';
END IF;
ELSE
                l_result := ' Tiếp cận khách hàng có : ' || p_tiep_can_id || ' không tồn tại';
END IF;

EXCEPTION
          WHEN OTHERS THEN
BEGIN
ROLLBACK TO KETQUA_THKH;
--ulog.plog.error(vc_tmp);
l_result := 'FALSE';
END;
END;
COMMIT;
RETURN l_result;
END;

-----------------------------------
--Lay danh sach ketqua tckh
FUNCTION FN_GET_DS_KETQUA_TCKH_SEL
RETURN SYS_REFCURSOR IS
     l_result      SYS_REFCURSOR;
BEGIN
OPEN l_result FOR
SELECT kqtckh.KETQUATC_ID ketQuaId, kqtckh.KETQUA_TCKH ketQuaTCKH
FROM css.KETQUA_TCKH kqtckh;

RETURN l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN

                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';

RETURN l_result;
END;
END;

----------------------------------------
FUNCTION FN_SEND_SMS_FOR_KEHOACH_CHK(
	p_tiepcan_id_lst IN VARCHAR2,
    p_phanvung_id IN NUMBER,
    p_ghichu IN VARCHAR2,
    p_may_cn IN VARCHAR2,
    p_nguoi_cn IN VARCHAR2,
    p_ip_cn IN VARCHAR2,
    p_ngay_cn	 IN DATE,
    p_ttpd_id IN NUMBER,
    p_url IN VARCHAR2)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_so_dt VARCHAR2(4000);
    l_noi_dung VARCHAR2(4000);
    l_noi_dung_call_sms VARCHAR2(4000);
    l_ma_kh VARCHAR2(4000);
    l_nhan_vien_id NUMBER;
BEGIN
SAVEPOINT update_bar;
BEGIN
     --get danh sach id tiep can
FOR rec IN (
                SELECT value
                FROM
                  (SELECT regexp_substr (p_tiepcan_id_lst, '[^,]+', 1, LEVEL) value
                   FROM dual CONNECT BY LEVEL <= LENGTH (p_tiepcan_id_lst) - LENGTH
                     (REPLACE (p_tiepcan_id_lst,',')) + 1))
         LOOP
            dbms_output.put_line(rec.value);
SELECT nhanvien.so_dt INTO l_so_dt
FROM admin.nhanvien
         JOIN tiepcan_kh ON (nhanvien.nhanvien_id = tiepcan_kh.nhanvien_id AND nhanvien.DONVI_ID = tiepcan_kh.DONVI_DUYET_Id AND nhanvien.PHANVUNG_ID = tiepcan_kh.PHANVUNG_ID)
         JOIN admin.NHANVIEN_LNV ON nhanvien.nhanvien_id = NHANVIEN_LNV.nhanvien_id
WHERE tiepcan_kh.TIEPCAN_ID = rec.value
  and NHANVIEN_LNV.loainv_id = 104
  AND tiepcan_kh.PHANVUNG_ID = p_phanvung_id
  and rownum = 1;
dbms_output.put_line(l_so_dt);

SELECT ma_kh, noidung, nhanvien_id INTO l_ma_kh, l_noi_dung, l_nhan_vien_id
FROM tiepcan_kh
WHERE tiepcan_kh.tiepcan_id = rec.value
  AND tiepcan_kh.PHANVUNG_ID = p_phanvung_id;

l_noi_dung_call_sms := 'Kế hoạch tiếp cận cần phê duyệt ' || l_ma_kh || ' ' || l_noi_dung || ' ' || p_url;
            IF l_so_dt IS NOT NULL THEN
            -- Tạo bản ghi vào queue tbale để gửi sms
            send_sms(p_phanvung_id, l_so_dt, l_noi_dung_call_sms, p_ghichu, p_may_cn, p_nguoi_cn, p_ip_cn);
END IF;

            -- tạo bản ghi giao phiếu TCKH
insert into GIAOPHIEU_TCKH
(GIAOPHIEU_ID,
 TIEPCAN_ID,
 NHANVIEN_ID,
 NHANVIEN_DUYET_ID,
 NOIDUNG,
 TTPH_ID,
 NGAY_CN,
 NGUOI_CN,
 MAY_CN,
 IP_CN,
 PHANVUNG_ID)

values(
          SEQ_GIAOPHIEU_TCKH.nextval,
          rec.value,
          L_nhan_vien_id,
          104,
          l_noi_dung,
          p_ttpd_id,
          p_ngay_cn,
          p_nguoi_cn,
          p_may_cn,
          p_ip_cn,
          p_phanvung_id);
l_result := 'TRUE';

END LOOP;
RETURN l_result;
EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO update_bar;
--                    ulog.plog.error(vc_tmp);
l_result := 'Co Loi xay ra ' || sqlerrm;
RETURN l_result;
END;
END;
RETURN l_result;
END;

------------------------------------
FUNCTION FN_SEND_SMS_FOR_NHIEMVU_CHK(
	p_nhiemvu_id_lst IN VARCHAR2,
    p_phanvung_id IN NUMBER,
    p_ghichu IN VARCHAR2,
    p_may_cn IN VARCHAR2,
    p_nguoi_cn IN VARCHAR2,
    p_ip_cn IN VARCHAR2)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_so_dt VARCHAR2(4000);
    l_noi_dung VARCHAR2(4000);
BEGIN
SAVEPOINT update_bar;
BEGIN
     --get danh sach id tiep can
FOR rec IN (
            SELECT value
                FROM
                  (SELECT regexp_substr (p_nhiemvu_id_lst, '[^,]+', 1, LEVEL) value
                   FROM dual CONNECT BY LEVEL <= LENGTH (p_nhiemvu_id_lst) - LENGTH
                     (REPLACE (p_nhiemvu_id_lst,',')) + 1))
         LOOP
SELECT nhanvien.so_dt , taodl_tc.noidung INTO l_so_dt, l_noi_dung
FROM admin.nhanvien
         JOIN taodl_tc ON (nhanvien.nhanvien_id = taodl_tc.nhanvien_nhan_id AND nhanvien.PHANVUNG_ID = taodl_tc.PHANVUNG_ID)
         JOIN admin.NHANVIEN_LNV ON nhanvien.nhanvien_id = NHANVIEN_LNV.nhanvien_id
WHERE taodl_tc.lantao_id = rec.value
  AND ROWNUM = 1
  and NHANVIEN_LNV.loainv_id = 104
  AND taodl_tc.PHANVUNG_ID = p_phanvung_id
  AND nhanvien.DONVI_ID = taodl_tc.DONVI_NHAN_ID ;
IF l_so_dt IS NOT NULL THEN
            send_sms(p_phanvung_id, l_so_dt, l_noi_dung, p_ghichu, p_may_cn, p_nguoi_cn, p_ip_cn);
END IF;
            l_result := 'TRUE';
END LOOP;
RETURN l_result;
EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO update_bar;
--                    ulog.plog.error(vc_tmp);
l_result := 'Co Loi xay ra ' ||sqlerrm;
RETURN l_result;
END;
END;
RETURN l_result;
END;
-------------------------------
-- get danh sach khach hang tiep can
FUNCTION FN_GET_DS_KHACH_HANG_TC_SEL (
    p_ma_nv IN VARCHAR2,
    p_trang_thai IN NUMBER,
    p_phanvung_id IN NUMBER)
    RETURN SYS_REFCURSOR IS
    l_result      SYS_REFCURSOR;
    l_sql      VARCHAR2(20000);
BEGIN
BEGIN
        --Lay thong tin danh sach khach hang
            IF p_trang_thai is null then
            l_sql :='SELECT khtc.MA_NV,
                   khtc.MA_KH maKhachHang,
                   khtc.TEN_KH tenKhachHang,
                   khtc.DIACHI_KH diaChiKhachHang,
                   khtc.MST mstKhachHang,
                   khtc.SO_GT soGiayToKhachHang,
                   null as trangThaiKhachHang,
                   khoikh.TEN_KHOI khoiKhachHang,
                   plkh.TEN_PLKH phanLoaiKhachHang,
                   khtc.KHACHHANG_ID khachHangId,
                   khtc.so_dt sdtKhachHang
            FROM ( SELECT kh.MA_KH,
                    kh.TEN_KH,
                    kh.DIACHI_KH,
                    kh.MST,
                    kh.SO_GT,
                    kh.KHACHHANG_ID,
                    kh.PHANLOAIKH_ID,
                    kh.so_dt,
                    tdltckh.LANTAO_ID,
                    tdltc.MA_NV
                   FROM DB_KHACHHANG kh
                            INNER JOIN TAODL_TCKH tdltckh ON kh.KHACHHANG_ID = tdltckh.KHACHHANG_ID
                            INNER JOIN TAODL_TC tdltc ON tdltc.LANTAO_ID = tdltckh.LANTAO_ID AND tdltc.MA_NV =  ''' || p_ma_nv  || '''
                            WHERE tdltckh.PHANVUNG_ID = ' || p_phanvung_id ||
                            ' and kh.PHANVUNG_ID = ' || p_phanvung_id ||
                            ' and tdltc.PHANVUNG_ID = ' || p_phanvung_id
                            || ') khtc
                     LEFT JOIN PHANLOAI_KH plkh ON khtc.PHANLOAIKH_ID = plkh.PHANLOAIKH_ID
                     LEFT JOIN DBKH_SUB dbkhsub ON dbkhsub.KHACHHANG_ID = khtc.KHACHHANG_ID
                     INNER JOIN KHOI_KH khoikh ON khoikh.KHOI_ID = dbkhsub.KHOI_ID
            WHERE 1=1 AND dbkhsub.PHANVUNG_ID = ' || p_phanvung_id ||
                    ' AND khoikh.PHANVUNG_ID = ' || p_phanvung_id;
else

        --Lay thong tin danh sach khach hang
            l_sql := ' SELECT khtc.MA_KH maKhachHang,
            khtc.TEN_KH tenKhachHang,
            khtc.DIACHI_KH diaChiKhachHang,
            khtc.MST mstKhachHang,
            khtc.SO_GT soGiayToKhachHang,
            CASE
                WHEN tckh.KHACHHANG_ID IS NULL  THEN ''not_ex_tckh''
                ELSE ''ex_tckh''
            END as trangThaiKhachHang,
            khoikh.TEN_KHOI khoiKhachHang,
            plkh.TEN_PLKH phanLoaiKhachHang,
            khtc.KHACHHANG_ID khachHangId,
            khtc.so_dt sdtKhachHang
            FROM TIEPCAN_KH tckh right join (
                    SELECT kh.MA_KH,
                    kh.TEN_KH,
                    kh.DIACHI_KH,
                    kh.MST,
                    kh.SO_GT,
                    kh.so_dt,
                    kh.KHACHHANG_ID,
                    kh.PHANLOAIKH_ID,
                    tdltckh.LANTAO_ID,
                    tdltc.MA_NV
                    FROM DB_KHACHHANG kh
                    INNER JOIN TAODL_TCKH tdltckh ON kh.KHACHHANG_ID = tdltckh.KHACHHANG_ID
                    INNER JOIN TAODL_TC tdltc ON tdltc.LANTAO_ID = tdltckh.LANTAO_ID AND tdltc.MA_NV =  ''' || p_ma_nv  || '''
                            WHERE tdltckh.PHANVUNG_ID = ' || p_phanvung_id ||
                            ' and kh.PHANVUNG_ID = ' || p_phanvung_id ||
                            ' and tdltc.PHANVUNG_ID = ' || p_phanvung_id
                    || ') khtc
                 ON (tckh.KHACHHANG_ID = khtc.KHACHHANG_ID and tckh.LANTAO_ID = khtc.LANTAO_ID)
                 LEFT JOIN PHANLOAI_KH plkh ON khtc.PHANLOAIKH_ID = plkh.PHANLOAIKH_ID
                 LEFT JOIN DBKH_SUB dbkhsub ON dbkhsub.KHACHHANG_ID = khtc.KHACHHANG_ID
                 INNER JOIN KHOI_KH khoikh ON khoikh.KHOI_ID = dbkhsub.KHOI_ID
             WHERE 1=1 AND dbkhsub.PHANVUNG_ID = ' || p_phanvung_id ||
                    ' AND khoikh.PHANVUNG_ID = ' || p_phanvung_id;
            -- Check p_ma_nv va trang thai = 1
            IF p_trang_thai = 1 THEN
                l_sql := l_sql || ' AND tckh.KHACHHANG_ID IS NOT NULL ';
                dbms_output.put_line('1');
END IF;

            -- trang thai = 2
            IF p_trang_thai = 2 THEN
                l_sql := l_sql || ' AND tckh.KHACHHANG_ID IS NULL ';
                dbms_output.put_line('1');
END IF;
end if;

    dbms_output.put_line(l_sql);
OPEN l_result FOR l_sql;
RETURN l_result;

EXCEPTION
            WHEN OTHERS THEN
BEGIN

                    --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                         || sqlerrm
                                         || ')'' name from dual';

RETURN l_result;
END;

END;
END FN_GET_DS_KHACH_HANG_TC_SEL;
        --------------------
    FUNCTION FN_GEN_MA_BAOGIA_SEL RETURN VARCHAR2 AS
        l_ma_baogia VARCHAR2(50);
        l_maxid VARCHAR2(10);
BEGIN
BEGIN
SELECT LPAD((SELECT MAX(baogia_id) + 1 FROM baogia), 6, '0')
INTO l_maxid
FROM dual;

--dbms_output.put_line(l_maxid);
IF l_maxid IS NOT NULL THEN
                l_ma_baogia    := 'BG' || l_maxid;
ELSE
                l_ma_baogia    := 'BG000001';
END IF;
            --dbms_output.put_line(l_ma_baogia);

EXCEPTION
            WHEN no_data_found THEN
                l_ma_baogia := '';
END;
RETURN TRIM(l_ma_baogia);

END;
------------------------------------
------------------------------------------------------
    -- api40
PROCEDURE SP_GET_DATA_KHTC_LDDV_AM_LIST(
    p_loai_chuong_trinh IN VARCHAR2,
    p_ten_chuong_trinh IN VARCHAR2,
    p_tu_ngay IN DATE,
    p_den_ngay IN DATE,
    p_pn_page_id IN NUMBER,
    p_pn_rec_per_page IN NUMBER,
    p_don_vi_id IN NUMBER,
    p_phan_vung_id IN NUMBER,
    v_cusor     OUT SYS_REFCURSOR,
    v_total     OUT number)
IS
    l_result      SYS_REFCURSOR;
    l_sql         VARCHAR2(20000);
BEGIN
    --Lay thong tin danh sach nhan vien
BEGIN

        -------p_loai_chuong_trinh = 'CTBH'
        IF p_loai_chuong_trinh = 'CTBH' THEN
            l_sql := ' select '''' nhanVienTc,
                    a.loai_ct loaiChuongTrinh,
                    a.ma_ct maChuongTrinh,
                    a.ten_ct tenChuongTrinh,
                    a.tuNgay,
                    a.denNgay,
                    sum (a.trang_thai_2) slGiaoTC,
                    sum (a.trang_thai_3) slThucHienTC,
                    sum (a.trang_thai_4) slConLai
                from (
                    select ct.loai_ct,
                    ct.ma_ct,
                    ct.ten_ct,
                    MIN(tk.ngay_cn) tuNgay,
                    MAX(tk.ngay_cn) denNgay,
                    COUNT(1) AS trang_thai_2,
                    COUNT(case when tk.trangthaitc_id = 5 OR tk.trangthaitc_id = 6 then 1 end) AS trang_thai_3,
                    COUNT(case when tk.trangthaitc_id = 1 OR tk.trangthaitc_id = 2 or tk.trangthaitc_id = 3 then 1 end) AS trang_thai_4 ';

            l_sql := l_sql || ' from ctbh_temp ct
                     join TIEPCAN_KH tk on ct.ma_ct=tk.MA_CT
                    where ct.loai_ct = ''CTBH'' ';

            IF p_don_vi_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.DONVI_DUYET_ID = ' || p_don_vi_id;
END IF;

            IF p_phan_vung_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.PHANVUNG_ID = ' || p_phan_vung_id;
END IF;

            IF p_tu_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_ten_chuong_trinh IS NOT NULL THEN
            l_sql := l_sql || ' and lower(ct.ten_ct) LIKE ''%' || lower(p_ten_chuong_trinh) || '%''';
END IF;

            l_sql := l_sql ||' group by ct.loai_ct,ct.ma_ct, ct.ten_ct ) a
                    group by loai_ct,a.ma_ct, a.ten_ct, a.tuNgay,a.denNgay ' ;
END IF;

        -----------p_loai_chuong_trinh = 'CTCSKH'

        IF p_loai_chuong_trinh = 'CTCSKH' THEN
            l_sql := ' select '''' nhanVienTc,
                    a.loai_ct loaiChuongTrinh,
                    a.ma_ct maChuongTrinh,
                    a.ten_ct tenChuongTrinh,
                    a.tuNgay,
                    a.denNgay,
                    sum (a.trang_thai_2) slGiaoTC,
                    sum (a.trang_thai_3) slThucHienTC,
                    sum (a.trang_thai_4) slConLai
                from (
                    select ct.loai_ct,
                    ct.ma_ct,
                    ct.ten_ct,
                    MIN(tk.ngay_cn) tuNgay,
                    MAX(tk.ngay_cn) denNgay,
                    COUNT(1) AS trang_thai_2,
                    COUNT(case when tk.trangthaitc_id = 5 OR tk.trangthaitc_id = 6 then 1 end) AS trang_thai_3,
                    COUNT(case when tk.trangthaitc_id = 1 OR tk.trangthaitc_id = 2 or tk.trangthaitc_id = 3 then 1 end) AS trang_thai_4 ';

            l_sql := l_sql || ' from CTCSKH_temp ct
                     join TIEPCAN_KH tk on ct.ma_ct=tk.MA_CT
                    where ct.loai_ct = ''CTCSKH'' ';

            IF p_don_vi_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.DONVI_DUYET_ID = ' || p_don_vi_id;
END IF;

            IF p_phan_vung_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.PHANVUNG_ID = ' || p_phan_vung_id;
END IF;

            IF p_tu_ngay IS NOT NULL THEN
            l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_ten_chuong_trinh IS NOT NULL THEN
            l_sql := l_sql || ' and lower(ct.ten_ct) LIKE ''%' || lower(p_ten_chuong_trinh) || '%''';
END IF;

                l_sql := l_sql ||' group by ct.loai_ct,ct.ma_ct, ct.ten_ct ) a
                    group by loai_ct,a.ma_ct, a.ten_ct, a.tuNgay,a.denNgay ' ;
END IF;
       -----------   p_loai_chuong_trinh = 'KHTN'
        IF p_loai_chuong_trinh = 'KHTN' THEN
            l_sql :=  ' select '''' nhanVienTc,
                    ''KHTN'' loaiChuongTrinh,
                    a.ma_kh maChuongTrinh,
                    null tenChuongTrinh,
                    a.tuNgay,
                    a.denNgay,
                    sum (a.trang_thai_2) slGiaoTC,
                    sum (a.trang_thai_3) slThucHienTC,
                    sum (a.trang_thai_4) slConLai
                from (
                    select ct.ma_kh,
                    MIN(ct.ngay_cn) tuNgay,
                    MAX(ct.ngay_cn) denNgay,
                    COUNT(1) AS trang_thai_2,
                    COUNT(case when ct.trangthaitc_id = 5 OR ct.trangthaitc_id = 6 then 1 end) AS trang_thai_3,
                    COUNT(case when ct.trangthaitc_id = 1 OR ct.trangthaitc_id = 2 or ct.trangthaitc_id = 3 then 1 end) AS trang_thai_4
                     from TIEPCAN_KH ct where 1=1 ';

            IF p_don_vi_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND ct.DONVI_DUYET_ID = ' || p_don_vi_id;
END IF;

            IF p_phan_vung_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND ct.PHANVUNG_ID = ' || p_phan_vung_id;
END IF;

            IF p_tu_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(ct.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(ct.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

            l_sql := l_sql ||' group by ct.ma_kh ) a
                    group by a.ma_kh, a.tuNgay,a.denNgay ' ;
END IF;

        -----------   p_loai_chuong_trinh = 'NVTC'

        IF p_loai_chuong_trinh = 'NVTC' THEN
            l_sql := ' select a.TEN_NV nhanVienTc,
                    a.loai_ct loaiChuongTrinh,
                    a.ma_ct maChuongTrinh,
                    a.ten_ct tenChuongTrinh,
                    a.tuNgay,
                    a.denNgay,
                    sum (a.trang_thai_2) slGiaoTC,
                    sum (a.trang_thai_3) slThucHienTC,
                    sum (a.trang_thai_4) slConLai
                from (
                    select nv.TEN_NV,
                    ct.loai_ct,
                    ct.ma_ct,
                    ct.ten_ct,
                    MIN(tk.ngay_cn) tuNgay,
                    MAX(tk.ngay_cn) denNgay,
                    COUNT(1) AS trang_thai_2,
                    COUNT(case when tk.trangthaitc_id = 5 OR tk.trangthaitc_id = 6 then 1 end) AS trang_thai_3,
                    COUNT(case when tk.trangthaitc_id = 1 OR tk.trangthaitc_id = 2 or tk.trangthaitc_id = 3 then 1 end) AS trang_thai_4 ';

            l_sql := l_sql || ' from TIEPCAN_KH tk
                    inner join
                    ( SELECT ctbh.ma_ct, ctbh.ten_ct, ctbh.loai_ct from ctbh_temp ctbh
                    UNION ALL
                     SELECT ctcskh.ma_ct,ctcskh.ten_ct, ctcskh.loai_ct from CTCSKH_temp ctcskh) ct
                    ON ct.ma_ct=tk.MA_CT
                    inner join admin.NHANVIEN nv on nv.NHANVIEN_ID = tk.NHANVIEN_ID
                    where 1=1 ';

            IF p_don_vi_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.DONVI_DUYET_ID = ' || p_don_vi_id;
END IF;

            IF p_phan_vung_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.PHANVUNG_ID = ' || p_phan_vung_id;
                 l_sql := l_sql || ' AND nv.PHANVUNG_ID = ' || p_phan_vung_id;
END IF;

            IF p_tu_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_ten_chuong_trinh IS NOT NULL THEN
            l_sql := l_sql || ' and nv.NHANVIEN_ID = ' || TO_NUMBER(p_ten_chuong_trinh);
END IF;

            l_sql := l_sql ||' group by nv.TEN_NV,ct.loai_ct,ct.ma_ct, ct.ten_ct ) a
                    group by a.TEN_NV,a.loai_ct,a.ma_ct, a.ten_ct, a.tuNgay,a.denNgay ' ;
END IF;

    --lay count data truoc khi qua phan trang
        dbms_output.put_line(v_total);
        v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);
--lay data cusor sau phan trang
        dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;


EXCEPTION
        WHEN OTHERS THEN
BEGIN
            --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                 || sqlerrm
                                 || ')'' name from dual';
v_total := 0;
            v_cusor := l_result;

END;
END;
END;

---pi38-39
PROCEDURE SP_GET_DATA_KHTC_AM_LIST (
    p_loai_chuong_trinh IN VARCHAR2,
    p_ten_chuong_trinh IN VARCHAR2,
    p_tu_ngay IN DATE,
    p_den_ngay IN DATE,
    p_pn_page_id IN NUMBER,
    p_pn_rec_per_page IN NUMBER,
    p_nhan_vien_id IN NUMBER,
    p_phan_vung_id IN NUMBER,
    v_cusor     OUT SYS_REFCURSOR,
    v_total     OUT number)
IS
    l_result      SYS_REFCURSOR;
    l_sql         VARCHAR2(20000);
BEGIN
    --Lay thong tin danh sach nhan vien
BEGIN

        IF p_loai_chuong_trinh = 'CTBH' THEN
            l_sql := ' select   a.loai_ct loaiChuongTrinh,
                                a.ma_ct maChuongTrinh,
                                a.ten_ct tenChuongTrinh,
                                a.tuNgay,
                                a.denNgay,
                                sum (a.trang_thai_2) slGiaoTC,
                                sum (a.trang_thai_3) slThucHienTC,
                                sum (a.trang_thai_4) slConLai
                        from (
                            select ct.loai_ct,
                            ct.ma_ct,
                            ct.ten_ct,
                            MIN(tk.ngay_cn) tuNgay,
                            MAX(tk.ngay_cn) denNgay,
                            COUNT(1) AS trang_thai_2,
                            COUNT(case when tk.trangthaitc_id = 5 OR tk.trangthaitc_id = 6 then 1 end) AS trang_thai_3,
                            COUNT(case when tk.trangthaitc_id = 1 OR tk.trangthaitc_id = 2 or tk.trangthaitc_id = 3 then 1 end) AS trang_thai_4 ';

            l_sql := l_sql || ' from ctbh_temp ct
                     join TIEPCAN_KH tk on ct.ma_ct=tk.ma_ct
                    where ct.loai_ct = ''CTBH'' ';

            IF p_nhan_vien_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.NHANVIEN_ID = ' || p_nhan_vien_id;
END IF;

            IF p_phan_vung_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.PHANVUNG_ID = ' || p_phan_vung_id;
END IF;

            IF p_tu_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;
            IF p_ten_chuong_trinh IS NOT NULL THEN
               l_sql := l_sql || ' AND lower(ct.TEN_CT) LIKE ''%' || lower(p_ten_chuong_trinh) || '%''' ;
END IF;
            l_sql := l_sql || ' group by ct.loai_ct,ct.ma_ct, ct.ten_ct ) a
                                group by a.loai_ct,a.ma_ct, a.ten_ct, a.tuNgay, a.denNgay ' ;
ELSE IF p_loai_chuong_trinh = 'CTCSKH' THEN
            l_sql := ' select   a.loai_ct loaiChuongTrinh,
                                a.ma_ct maChuongTrinh,
                                a.ten_ct tenChuongTrinh,
                                a.tuNgay,
                                a.denNgay,
                                sum (a.trang_thai_2) slGiaoTC,
                                sum (a.trang_thai_3) slThucHienTC,
                                sum (a.trang_thai_4) slConLai
                        from (
                            select ct.loai_ct,
                            ct.ma_ct,
                            ct.ten_ct,
                            MIN(tk.ngay_cn) tuNgay,
                            MAX(tk.ngay_cn) denNgay,
                            COUNT(1) AS trang_thai_2,
                            COUNT(case when tk.trangthaitc_id = 5 OR tk.trangthaitc_id = 6 then 1 end) AS trang_thai_3,
                            COUNT(case when tk.trangthaitc_id = 1 OR tk.trangthaitc_id = 2 or tk.trangthaitc_id = 3 then 1 end) AS trang_thai_4 ';

            l_sql := l_sql || ' from ctcskh_temp ct
                     join TIEPCAN_KH tk on ct.ma_ct=tk.ma_ct
                    where ct.loai_ct = ''CTCSKH'' ';

            IF p_nhan_vien_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.NHANVIEN_ID = ' || p_nhan_vien_id;
END IF;

            IF p_phan_vung_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.PHANVUNG_ID = ' || p_phan_vung_id;
END IF;

            IF p_tu_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_ten_chuong_trinh IS NOT NULL THEN
               l_sql := l_sql || ' AND lower(ct.TEN_CT) LIKE ''%' || lower(p_ten_chuong_trinh) || '%''' ;
END IF;

            l_sql := l_sql || ' group by ct.loai_ct,ct.ma_ct, ct.ten_ct ) a
                                group by a.loai_ct,a.ma_ct, a.ten_ct, a.tuNgay, a.denNgay ' ;

ELSE IF p_loai_chuong_trinh = 'KHTN' THEN
            l_sql :=  ' select ''KHTN'' loaiChuongTrinh,
                                a.ma_kh maChuongTrinh,
                                null tenChuongTrinh,
                                a.tuNgay,
                                a.denNgay,
                                sum (a.trang_thai_2) slGiaoTC,
                                sum (a.trang_thai_3) slThucHienTC,
                                sum (a.trang_thai_4) slConLai
                        from (
                            select
                            ct.ma_kh,
                            MIN(ct.ngay_cn) tuNgay,
                            MAX(ct.ngay_cn) denNgay,
                            COUNT(1) AS trang_thai_2,
                            COUNT(case when ct.trangthaitc_id = 5 OR ct.trangthaitc_id = 6 then 1 end) AS trang_thai_3,
                            COUNT(case when ct.trangthaitc_id = 1 OR ct.trangthaitc_id = 2 or ct.trangthaitc_id = 3 then 1 end) AS trang_thai_4
                    from TIEPCAN_KH ct where 1=1 ';

            IF p_nhan_vien_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND ct.NHANVIEN_ID = ' || p_nhan_vien_id;
END IF;

            IF p_phan_vung_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND ct.PHANVUNG_ID = ' || p_phan_vung_id;
END IF;

            IF p_tu_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(ct.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(ct.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

            l_sql := l_sql || ' group by ct.ma_kh) a
                                group by a.ma_kh, a.tuNgay, a.denNgay ' ;
END IF;
END IF;
END IF;
    --lay count data truoc khi qua phan trang
        dbms_output.put_line(v_total);
        v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);
--lay data cusor sau phan trang
        dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN
            --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                 || sqlerrm
                                 || ')'' name from dual';
v_total := 0;
            v_cusor := l_result;

END;
END;
END;


--api16
FUNCTION FN_GET_EXPORT_KHACHHANG_CHUAKH_SEL
        (p_id_tiep_can_lst  IN VARCHAR2,
        p_phan_vung_id IN NUMBER)
         RETURN SYS_REFCURSOR IS
        l_result      SYS_REFCURSOR;
         l_sql      VARCHAR2(20000);
         l_id_tiep_can_list      VARCHAR2(20000);
BEGIN
BEGIN
            l_sql := ' SELECT khtc.NGAY_GIAO ngayGiao,
                khtc.MA_NV maNhiemVu,
                khtc.LOAINV_ID loaiNhiemVu,
                khtc.MA_KH maKhachHang,
                khtc.TEN_KH tenKhachHang,
                khtc.DIACHI_KH diaChiKhachHang,
                khtc.MST mstKhachHang,
                khtc.SO_GT soGiayToKhachHang,
                khtc.SO_DT soDienThoai,
                khtc.EMAIL email,
                kkh.TEN_KHOI khoiKhachHang,
                plkh.TEN_PLKH phanLoaiKhachHang,
                khtc.soLuongCTBH,
                dvvt.TEN_DVVT tenDichVu,
                lhtb.LOAIHINH_TB loaiHinh,
                '''' vatPham,
                tckh.NGUOI_LH nguoiLienHe,
                tckh.SDT_LH soDienThoaiLienHe,
                khtc.NGAY_TH hanThucHien,
                TO_CHAR(tckh.NGAY_TC, ''DD/MM/YYYY'') ngayTiepCan,
                tckh.HINHTHUC hinhThuc,
                khtc.NOIDUNG noiDungTiepCan,
                tckh.CHUCVU_LH chucVu
            FROM TIEPCAN_KH tckh right join
                (
                        SELECT kh.PHANVUNG_ID,kh.MA_KH,
                        kh.TEN_KH,
                        kh.DIACHI_KH,
                        kh.MST,
                        kh.SO_GT,
                        kh.SO_DT,
                        kh.EMAIL,
                        kh.KHACHHANG_ID,
                        kh.PHANLOAIKH_ID,
                        tdltckh.LANTAO_ID,
                        tdltc.MA_NV,
                        TO_CHAR(tdltc.NGAY_GIAO, ''DD/MM/YYYY'') NGAY_GIAO,
                        tdltc.LOAINV_ID,
                        tdltc.DICHVUVT_ID,
                        tdltc.LOAITB_ID,
                        TO_CHAR(tdltc.NGAY_TH, ''DD/MM/YYYY'') NGAY_TH,
                        tdltc.NOIDUNG,
                        (select count(ma_ct) from ctbh_temp where khachhang_id = kh.khachhang_id) soLuongCTBH,
                        tdltc.TRANGTHAI
                        FROM DB_KHACHHANG kh
                        INNER JOIN TAODL_TCKH tdltckh ON kh.KHACHHANG_ID = tdltckh.KHACHHANG_ID
                        INNER JOIN TAODL_TC tdltc ON tdltc.LANTAO_ID = tdltckh.LANTAO_ID
                        WHERE tdltckh.PHANVUNG_ID = ' || p_phan_vung_id ||
                        ' and tdltc.PHANVUNG_ID = ' || p_phan_vung_id  ||
                        ' and kh.PHANVUNG_ID = ' || p_phan_vung_id;

            IF p_id_tiep_can_lst IS NOT NULL THEN
                FOR rec IN (
                    SELECT value
                    FROM
                        (SELECT regexp_substr (p_id_tiep_can_lst, '[^,]+', 1, LEVEL) value
                    FROM dual CONNECT BY LEVEL <= LENGTH (p_id_tiep_can_lst) - LENGTH
                        (REPLACE (p_id_tiep_can_lst,',')) + 1))
                LOOP
                    l_id_tiep_can_list := l_id_tiep_can_list || '' || rec.value || ',';
END LOOP;

                l_id_tiep_can_list := RTRIM(SUBSTR(l_id_tiep_can_list, 0, LENGTH(l_id_tiep_can_list) -1));
                dbms_output.put_line(l_id_tiep_can_list);
                l_sql := l_sql || ' AND tdltc.LANTAO_ID IN (' || l_id_tiep_can_list || ')';

END IF;

            l_sql := l_sql || ') khtc ON (tckh.KHACHHANG_ID = khtc.KHACHHANG_ID and tckh.LANTAO_ID = khtc.LANTAO_ID)
             inner JOIN PHANLOAI_KH plkh ON khtc.PHANLOAIKH_ID = plkh.PHANLOAIKH_ID
             left join DBKH_SUB khsub ON (khsub.KHACHHANG_ID = khtc.KHACHHANG_ID AND khsub.PHANVUNG_ID = khtc.PHANVUNG_ID)
             left join KHOI_KH kkh ON (kkh.KHOI_ID = khsub.KHOI_ID AND kkh.PHANVUNG_ID = khsub.PHANVUNG_ID)
             left join DICHVU_VT dvvt ON dvvt.DICHVUVT_ID = khtc.DICHVUVT_ID
             left join LOAIHINH_TB lhtb ON lhtb.LOAITB_ID = khtc.LOAITB_ID
             WHERE 1=1 AND tckh.KHACHHANG_ID IS NULL AND khtc.TRANGTHAI = 2
             ORDER BY tckh.ngay_cn DESC';

            dbms_output.put_line(l_sql);
OPEN l_result FOR l_sql;
RETURN l_result;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
OPEN l_result FOR 'select ''Co Lo xay ra('
                                         || sqlerrm
                                         || ')'' name from dual';
RETURN l_result;
END;
END;
END;

    -------------------------------------------------------------
    --api48
    FUNCTION FN_GET_NHIEM_VU_CHI_TIET_SEL(
      p_id_nhiemvu IN NUMBER,
      p_phanvung_id IN NUMBER)
    RETURN SYS_REFCURSOR IS
         v_cusor   SYS_REFCURSOR;
         l_sql      VARCHAR2(20000);
BEGIN
        l_sql := 'SELECT taodl_tc.MA_NV maNhiemVuDLTC,';
        l_sql := l_sql || 'taodl_tc.loainv_id loaiNhiemVuId,';
        l_sql := l_sql || 'taodl_tckh.khachhang_id khachHangId,';
        l_sql := l_sql || 'kh.MA_KH maKhachHang,';
        l_sql := l_sql || 'kh.TEN_KH tenKhachHang,';
        l_sql := l_sql || 'kh.DIACHI_KH diaChiKhachHang,';
        l_sql := l_sql || 'kh.MST maSoThueKhachHang,';
        l_sql := l_sql || 'kh.SO_GT soGiayToKhachHang, ';
        l_sql := l_sql || 'taodl_tc.LANTAO_ID nhiemVuId, ';
        l_sql := l_sql || 'taodl_tc.DICHVUVT_ID dichVuVTID, ';
        l_sql := l_sql || 'taodl_tc.LOAITB_ID loaiThietBiId, ';
        l_sql := l_sql || 'taodl_tc.NOIDUNG noiDung ';

        l_sql := l_sql || 'FROM taodl_tc ';
        l_sql := l_sql || 'LEFT JOIN taodl_tckh ON (taodl_tc.LANTAO_ID = taodl_tckh.LANTAO_ID and taodl_tckh.phanvung_id = taodl_tc.phanvung_id)';
        l_sql := l_sql || 'INNER JOIN db_khachhang kh ON kh.KHACHHANG_ID = taodl_tckh.KHACHHANG_ID ';
        l_sql := l_sql || 'WHERE taodl_tc.LANTAO_ID = ' || p_id_nhiemvu ;
        l_sql := l_sql || ' AND taodl_tc.phanvung_id = ' || p_phanvung_id ;
        l_sql := l_sql || ' AND kh.phanvung_id  = ' || p_phanvung_id ;

        dbms_output.put_line(l_sql);
OPEN v_cusor FOR l_sql;
RETURN v_cusor;

EXCEPTION
        WHEN OTHERS THEN
BEGIN
OPEN v_cusor FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';
RETURN v_cusor;
END;
END;

-- api 42
FUNCTION FN_LAY_TOC_DO_SEL(p_id_dich_vu IN NUMBER, p_id_loai_hinh_tb IN NUMBER)
RETURN SYS_REFCURSOR
IS
l_result      SYS_REFCURSOR;
l_sql          VARCHAR2(4000);
BEGIN
    IF p_id_dich_vu = 7 OR p_id_dich_vu = 8 OR p_id_dich_vu = 9 THEN

    l_sql := 'SELECT tocdo_id idTocDo, TO_CHAR(tocdo) tocDo, donvi donVi FROM tocdo_kenh ';

ELSE l_sql := 'SELECT tocdo_id idTocDo, tocdo tocDo FROM tocdo_adsl WHERE loaitb_id = ' || p_id_loai_hinh_tb ;

END IF;

OPEN l_result FOR l_sql;
RETURN l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN

                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';

RETURN l_result;
END;
END;
--- api43
function FN_GET_MUCCUOC_TB_SEL(
    p_id_toc_do IN NUMBER,
    p_id_dich_vu_vt IN NUMBER,
    p_phan_vung_id IN NUMBER
    ) RETURN SYS_REFCURSOR IS
    l_result SYS_REFCURSOR;
    l_sql      VARCHAR2(20000);
BEGIN

    l_sql := 'select mctb.cuoc_tb mucCuocTB, mctb.MUCCUOC tenMucCuocTB, mctb.MUCUOCTB_ID idMucCuocTB
              from MUCCUOC_TB mctb
              where 1 = 1';

    IF p_id_dich_vu_vt <> 0 then
        l_sql := l_sql || ' and  mctb.dichvuvt_id = ' || p_id_dich_vu_vt;
END IF;

    IF p_id_toc_do <> 0 then
        l_sql := l_sql || ' and  mctb.tocdo_id = ' || p_id_toc_do;
END IF;

    IF p_id_toc_do <> 0 then
        l_sql := l_sql || ' and  mctb.PHANVUNG_ID = ' || p_phan_vung_id;
END IF;

    l_sql := l_sql || ' order by mctb.mucuoctb_id
              FETCH FIRST 1 ROWS ONLY';

    dbms_output.put_line(l_sql);
OPEN l_result FOR l_sql;
RETURN l_result;
exception
    WHEN OTHERS THEN
BEGIN
                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';

RETURN l_result;
END;
END;
-- api 45
FUNCTION FN_LAY_KM_GOI_DA_DICH_VU_SEL
(p_id_dich_vu IN NUMBER,
p_phanvung_id   IN NUMBER)
RETURN SYS_REFCURSOR
IS
l_result      SYS_REFCURSOR;
l_sql          VARCHAR2(4000);
BEGIN
OPEN l_result FOR
SELECT distinct a.KHUYENMAI_ID idKhuyenMai, a.TEN_KM tenKhuyenMai
FROM khuyenmai a, CTKM_KM b, CT_KHUYENMAI c
WHERE a.DICHVUVT_ID = p_id_dich_vu AND a.LOAI_KM = 1
  AND a.KHUYENMAI_ID = b.KHUYENMAI_ID AND b.CHITIETKM_ID = c. CHITIETKM_ID
  and trunc(sysdate) between a.NGAY_BD and nvl(a.NGAY_KT, TRUNC(SYSDATE) +1)
  and a.phanvung_id = p_phanvung_id
  and b.phanvung_id = p_phanvung_id
  and c.phanvung_id = p_phanvung_id;

RETURN l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN

                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';

RETURN l_result;
END;
END;
--------------------------
-- api 47
FUNCTION FN_LAY_KMMT_SEL
(p_phan_vung_id IN NUMBER)
RETURN SYS_REFCURSOR
IS
l_result      SYS_REFCURSOR;
l_sql          VARCHAR2(4000);
BEGIN
OPEN l_result FOR
select KHOANMUCTT_ID idKhoanMuc,
       TEN_KMTT tenKhoanMuc,
       TYLE_VAT tyLeVAT
from KHOANMUC_TT
where PHANVUNG_ID = p_phan_vung_id and LOAI = 1;

RETURN l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN

                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';

RETURN l_result;
END;
END;
--api44
PROCEDURE SP_GET_DS_GOI_DA_DV_LIST(
  p_id_dich_vu_vt IN NUMBER,
  p_id_loai_hinh_tb IN NUMBER,
  p_id_toc_do IN NUMBER,
  p_pn_page_id IN NUMBER,
  p_pn_rec_per_page IN NUMBER,
  p_phanvung_id   IN NUMBER,
  v_cusor     OUT SYS_REFCURSOR,
  v_total     OUT number
  )
is
     l_result   SYS_REFCURSOR;
     l_sql      VARCHAR2(20000);
BEGIN
    --Lay thong tin danh sach
    l_sql := 'SELECT dadv.GOI_ID goiId, dadv.MA_GOI maGoi, dadv.TEN_GOI tenGoi, lhtb. TIEN_GOI giaTien, lhtb. VAT_GOI vat,(lhtb.TIEN_GOI + lhtb.VAT_GOI) as tongTien
                from CSS.GOI_DADV dadv
                join  CSS.GOI_DADV_LHTB lhtb on dadv.GOI_ID = lhtb.GOI_ID and dadv.TRANGTHAI = 1
                join css.LOAIHINH_TB htb on htb.LOAITB_ID = lhtb.LOAITB_ID
                join css.DICHVU_VT dvvt on dvvt.DICHVUVT_ID = htb.DICHVUVT_ID
                Where 1 = 1 ';

        if p_id_dich_vu_vt is not null  then
            l_sql := l_sql || ' and dvvt.DICHVUVT_ID = ' || p_id_dich_vu_vt;
end if;

        if p_id_loai_hinh_tb is not null  then
            l_sql := l_sql || ' and htb.LOAITB_ID = ' || p_id_loai_hinh_tb;
end if;

        if p_id_toc_do is not null  then
            l_sql := l_sql || ' and lhtb.TOCDO_ID = ' || p_id_toc_do;
end if;

        l_sql := l_sql || ' and dadv.phanvung_id = ' || p_phanvung_id;
        l_sql := l_sql || ' and lhtb.phanvung_id = ' || p_phanvung_id;

        --lay count data truoc khi qua phan trang
        dbms_output.put_line(v_total);
        v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);

        --lay data cusor sau phan trang
        dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN
                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';
v_total := 0;
                v_cusor := l_result;

END;

END;
--api46
PROCEDURE SP_GET_DSKH_GOI_DA_DV_LIST(
  p_id_khuyen_mai IN NUMBER,
  p_pn_page_id IN NUMBER,
  p_pn_rec_per_page IN NUMBER,
  p_phanvung_id IN NUMBER,
  v_cusor     OUT SYS_REFCURSOR,
  v_total     OUT number
  )
is
     l_result   SYS_REFCURSOR;
     l_sql      VARCHAR2(20000);
BEGIN
    --Lay thong tin danh sach
    l_sql := 'select ctkm.CHITIETKM_ID chiTietKhuyenMaiId, ctkm.NOIDUNG chiTietKhuyenMai, ctkm.DATCOC_CSD tienTraTruoc,ctkm.TYLE_VAT vat,
                (ctkm.TYLE_VAT + ctkm.DATCOC_CSD) as tongTien
              from css.CT_KHUYENMAI ctkm
              Where 1 = 1 AND PHANVUNG_ID = ' || p_phanvung_id;

        if p_id_khuyen_mai is not null  then
            l_sql := l_sql || ' and ctkm.KHUYENMAI_ID = ' || p_id_khuyen_mai;
end if;

        --lay count data truoc khi qua phan trang
        dbms_output.put_line(v_total);
        v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);

        --lay data cusor sau phan trang
        dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN
                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';
v_total := 0;
                v_cusor := l_result;

END;

END;
-- api 49
PROCEDURE SP_GET_DS_BAO_GIA_LIST(
  p_trang_thai_bao_gia IN LIST_NUMBER,
  p_nhan_vien_id IN NUMBER,
  p_pn_page_id IN NUMBER,
  p_pn_rec_per_page IN NUMBER,
  p_phanvung_id   IN NUMBER,
  v_cusor     OUT SYS_REFCURSOR,
  v_total     OUT number
  )
is
     l_result   SYS_REFCURSOR;
     l_sql      VARCHAR2(20000);
     l_trang_thai_bao_gia      VARCHAR2(20000);
     l_countTotal number:=0;
     l_count_record NUMBER(1);
BEGIN

SELECT COUNT(1) INTO l_count_record FROM trangthai_bg
WHERE trangthai_bg.TTBG_ID member of p_trang_thai_bao_gia;

IF l_count_record = p_trang_thai_bao_gia.COUNT THEN

        FOR rec IN (SELECT TTBG_ID FROM trangthai_bg
            WHERE trangthai_bg.TTBG_ID member of p_trang_thai_bao_gia)
        LOOP
            l_trang_thai_bao_gia := l_trang_thai_bao_gia || ',' || rec.TTBG_ID;
END LOOP;

        l_trang_thai_bao_gia  := SUBSTR(l_trang_thai_bao_gia, 2, LENGTH(l_trang_thai_bao_gia) -1);

         --Lay thong tin danh sach dich vu
        l_sql := 'SELECT bg.baogia_id idBaoGia ,
            bg.ma_baogia maBaoGia ,
            bg.ten_baogia tenBaoGia ,
            bg.han_pheduyet hanPheDuyet ,
            bg.han_lapdat hanLapDat ,
            bg.hieuluc_tu hieuLucTuNgay ,
            bg.hieuluc_den hieuLucDenNgay ,
            bg.loaibg_id loaiBaoGia ,
            bg.nhom_dv nhomDichVu ,
            bg.nguon nguon ,
            bg.nguon_id nguonId ,
            kh.khachhang_id idKhachHang ,
            kh.ma_kh maKhachHang ,
            kh.ten_kh tenKhachHang ,
            kh.diachi_kh diaChiKhachHang ,
            kh.mst mstKhachHang ,
            bg.nguoi_lh nguoiLienHe ,
            bg.so_dt soDienThoaiLienHe ,
            bg.email emailLienHe ,
            bg.ghichu ghiChu,
            loaibg.loai_bg tenLoaiBaoGia,
            bg.donvi_id IDDonVIBaoGia,
            donvi.ten_dv tenDonViBaoGia
            FROM baogia bg
            JOIN db_khachhang kh ON kh.khachhang_id = bg.khachhang_id
            JOIN loai_bg loaibg on loaibg.loaibg_id = bg.loaibg_id
            JOIN admin.donvi donvi on donvi.donvi_id = bg.donvi_id';

            l_sql := l_sql || ' where bg.ttbg_id IN( ' ||  l_trang_thai_bao_gia || ')' ;
            l_sql := l_sql || ' and bg.nhanvien_id = ' ||  p_nhan_vien_id;
            l_sql := l_sql || ' and bg.phanvung_id = ' ||  p_phanvung_id;
            l_sql := l_sql || ' and kh.phanvung_id = ' ||  p_phanvung_id;
            l_sql := l_sql || ' and donvi.phanvung_id = ' ||  p_phanvung_id;
            l_sql := l_sql || ' ORDER BY bg.ngay_cn DESC ';


            --lay count data truoc khi qua phan trang
            dbms_output.put_line(v_total);
            v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);

            --lay data cusor sau phan trang
            dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;
ELSE
            --OPEN l_result FOR 'select ''FALSE'' from dual';
                v_total := -1;
                v_cusor := null;
END IF;
EXCEPTION
        WHEN OTHERS THEN
BEGIN
                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';
v_total := 0;
                v_cusor := l_result;

END;
END;
-- api 53
PROCEDURE SP_LAY_CHI_TIET_KHACH_HANG_TC
( p_id_khach_hang IN NUMBER,
  p_phan_vung_id IN NUMBER,
  v_cusor OUT SYS_REFCURSOR )
IS
  l_result      SYS_REFCURSOR;
BEGIN
OPEN l_result FOR
SELECT kh.KHACHHANG_ID khachHangId,
       kh.MA_KH maKhachHang,
       kh.TEN_KH tenKhachHang,
       kh.DIACHI_KH diaChiKhachHang,
       kh.MST mstKhachHang,
       kh.SO_GT soGiayToKhachHang,
       khoikh.TEN_KHOI khoiKhachHang,
       plkh.TEN_PLKH phanLoaiKhachHang,
       Kh.SO_DT sdtKhachHang
FROM css.DB_KHACHHANG kh
         INNER JOIN css.PHANLOAI_KH plkh ON kh.PHANLOAIKH_ID = plkh.PHANLOAIKH_ID
         LEFT JOIN css.DBKH_SUB dbkhsub ON (dbkhsub.KHACHHANG_ID = kh.KHACHHANG_ID and dbkhsub.phanvung_id = kh.phanvung_id)
         INNER JOIN css.KHOI_KH khoikh ON khoikh.KHOI_ID = dbkhsub.KHOI_ID
where kh.KHACHHANG_ID = p_id_khach_hang
  and kh.PHANVUNG_ID = p_phan_vung_id
  and khoikh.PHANVUNG_ID = p_phan_vung_id;
v_cusor := l_result;

EXCEPTION
          WHEN OTHERS THEN
BEGIN
               --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';
v_cusor := l_result;
END;
END;

--api 51
FUNCTION FN_XOA_BAOGIA_CHK(
        p_bao_gia_id_lst IN LIST_NUMBER,
		p_phanvung_id IN NUMBER)
        return VARCHAR2
        IS
        l_result VARCHAR2(4000);
        l_ma_baogia VARCHAR2(2000);
        l_count_record NUMBER(1);
BEGIN
BEGIN
SAVEPOINT delete_bar;

SELECT count(BAOGIA_ID) INTO l_count_record
FROM BAOGIA
WHERE BAOGIA_ID member of p_bao_gia_id_lst
        AND (TTBG_ID = 1 OR TTBG_ID = 7 OR TTBG_ID = 8) AND PHANVUNG_ID = p_phanvung_id;

IF l_count_record = p_bao_gia_id_lst.COUNT  THEN
DELETE FROM BAOGIA_TBI WHERE baogia_id member of p_bao_gia_id_lst AND PHANVUNG_ID = p_phanvung_id;
DELETE FROM BAOGIA_DVGT WHERE baogia_id member of p_bao_gia_id_lst AND PHANVUNG_ID = p_phanvung_id;
DELETE FROM BAOGIA_GC WHERE baogia_id member of p_bao_gia_id_lst;
DELETE FROM CT_TIENBG WHERE baogia_id member of p_bao_gia_id_lst AND PHANVUNG_ID = p_phanvung_id;
DELETE FROM BAOGIA_CTKM WHERE baogia_id member of p_bao_gia_id_lst;
DELETE FROM BAOGIA WHERE baogia_id member of p_bao_gia_id_lst AND PHANVUNG_ID = p_phanvung_id;

l_result := 'SUCCESS';
ELSE
            FOR abc in (select MA_BAOGIA from BAOGIA WHERE PHANVUNG_ID = p_phanvung_id AND baogia_id member of p_bao_gia_id_lst)
            LOOP
               l_ma_baogia := l_ma_baogia || ', ' || abc.MA_BAOGIA;
END LOOP;

            l_ma_baogia := RTRIM(SUBSTR(l_ma_baogia,2,LENGTH(l_ma_baogia) ));
            l_result := 'Các mã báo giá sau : ' || l_ma_baogia ||' không hợp lệ! vui lòng kiểm tra lại';
END IF;

EXCEPTION

                WHEN OTHERS THEN
BEGIN
ROLLBACK TO delete_bar;
--ulog.plog.error(vc_tmp);
l_result := 'FALSE';
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END FN_XOA_BAOGIA_CHK;

--api35
FUNCTION FN_GET_LOAI_BAOGIA_SEL
(p_screen_id IN NUMBER,
p_phan_vung_id IN NUMBER)
RETURN SYS_REFCURSOR IS
     l_result      SYS_REFCURSOR;
BEGIN
    IF p_screen_id = 1 THEN
        IF p_phan_vung_id = 97 THEN
            OPEN l_result FOR
SELECT lbg.LOAIBG_ID loaiBgId, lbg.LOAI_BG loaiBg
FROM css.LOAI_BG lbg
WHERE lbg.LOAIBG_ID in (1, 2, 5);
ELSE
            OPEN l_result FOR
SELECT lbg.LOAIBG_ID loaiBgId, lbg.LOAI_BG loaiBg
FROM css.LOAI_BG lbg
WHERE lbg.LOAIBG_ID in (1, 3, 4, 5, 6);
END IF;
ELSE
        IF p_phan_vung_id = 97 THEN
            OPEN l_result FOR
SELECT lbg.LOAIBG_ID loaiBgId, lbg.LOAI_BG loaiBg
FROM css.LOAI_BG lbg
WHERE lbg.LOAIBG_ID in (2, 4, 5, 6);
ELSE
            OPEN l_result FOR
SELECT lbg.LOAIBG_ID loaiBgId, lbg.LOAI_BG loaiBg
FROM css.LOAI_BG lbg
WHERE lbg.LOAIBG_ID in (3);
END IF;
END IF;

RETURN l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN

                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';

RETURN l_result;
END;
END;


PROCEDURE SP_TAO_MOI_BAOGIA_INS
(
    p_baogia_id                         IN NUMBER,
    p_ma_baogia                         IN VARCHAR2,
    p_ten_baogia                        IN VARCHAR2,
    p_han_phe_duyet                     IN DATE,
    p_han_lap_dat                       IN DATE,
    p_hieu_luc_tu_ngay                  IN DATE,
    p_hieu_luc_den_ngay                 IN DATE,
    p_loai_baogia                       IN NUMBER,
    p_nhom_dichvu                       IN VARCHAR2,
    p_nguon_baogia                      IN NUMBER,
    p_nguon_baogia_id                   IN NUMBER,
    p_khachhang_id                      IN NUMBER,
    p_nguoi_lienhe                      IN VARCHAR2,
    p_sdt_lienhe                        IN VARCHAR2,
    p_email_lienhe                      IN VARCHAR2,
    p_ghi_chu                           IN VARCHAR2,
    p_lst_chitiet_khoanmuc              IN LIST_CHI_TIET_KHOANMUC,
    p_ngay_cn 				            IN DATE,
	p_nguoi_cn 				            IN VARCHAR2,
	p_may_cn 				            IN VARCHAR2,
	p_ip_cn 					        IN VARCHAR2,
    p_nhanvien_id 			            IN NUMBER,
	p_phanvung_id    		            IN NUMBER,
    p_donvi_id                          IN NUMBER,
    l_result            	            OUT SYS_REFCURSOR
)
IS
    n 			NUMBER;
    l_baogia_id NUMBER;
    l_baogia_tbi_id NUMBER;
    l_baogia_dvgt_id NUMBER;
    l_baogia_gc_id NUMBER;
    l_tyle_vat  NUMBER NULL;
    l_tyle_vat_id   NUMBER NULL;
    l_tien_tragop NUMBER NULL;
    l_vat_tragop NUMBER NULL;
    l_block_dau NUMBER NULL;
    l_block_tiep NUMBER NULL;
    l_gia_block_tiep NUMBER NULL;
    l_vat_block_tiep NUMBER NULL;
    l_cuoc_sd NUMBER NULL;
    l_vat_sd NUMBER NULL;
    l_he_so NUMBER NULL;
    l_gc_tien NUMBER NULL;
    l_gc_vat NUMBER NULL;
    l_count NUMBER;
BEGIN
SAVEPOINT ABC;
l_baogia_id := SEQ_BAO_GIA.nextval;
        l_tyle_vat := 0;
        l_tyle_vat_id := 0;
        l_count := 0;

INSERT INTO BAOGIA
(   BAOGIA_ID,
    PHANVUNG_ID,
    NGUON,
    NGUON_ID,
    MA_BAOGIA,
    TEN_BAOGIA,
    HAN_PHEDUYET,
    HAN_LAPDAT,
    HIEULUC_TU,
    HIEULUC_DEN,
    LOAIBG_ID,
    KHACHHANG_ID,
    NGUOI_LH,
    SO_DT,
    EMAIL,
    GHICHU,
    TTBG_ID,
    NGUOI_CN,
    IP_CN,
    MAY_CN,
    NGAY_CN,
    DONVI_ID,
    NHANVIEN_ID,
    NHOM_DV
)
VALUES
    (   l_baogia_id,
        p_phanvung_id,
        p_nguon_baogia,
        p_nguon_baogia_id,
        p_ma_baogia,
        p_ten_baogia,
        p_han_phe_duyet,
        p_han_lap_dat,
        p_hieu_luc_tu_ngay,
        p_hieu_luc_den_ngay,
        p_loai_baogia,
        p_khachhang_id,
        p_nguoi_lienhe,
        p_sdt_lienhe,
        p_email_lienhe,
        p_ghi_chu,
        1,
        p_nguoi_cn,
        p_ip_cn,
        p_may_cn,
        p_ngay_cn,
        p_donvi_id,
        p_nhanvien_id,
        p_nhom_dichvu
    );

IF p_lst_chitiet_khoanmuc IS NOT NULL THEN

            FOR i IN 1..p_lst_chitiet_khoanmuc.COUNT LOOP

                -- TH PHI_KHAC
                IF p_lst_chitiet_khoanmuc(i).type = 'PHI_KHAC' THEN
                    -- Insert số lượng bản ghi = soluong input
                    -- ID=1, LOAI_ID=1
SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = p_lst_chitiet_khoanmuc(i).khoanMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT, TYLE_VAT_ID INTO l_tyle_vat, l_tyle_vat_id FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = p_lst_chitiet_khoanmuc(i).khoanMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
FOR pk IN 1..p_lst_chitiet_khoanmuc(i).soLuong LOOP
                        -- INSERT LOAI_ID 1, ID 1
                        INSERT INTO CT_TIENBG
                        (
                            ID,
                            PHANVUNG_ID,
                            BAOGIA_ID,
                            TIEN,
                            VAT,
                            KHOANMUCTT_ID,
                            TYLE_VAT,
                            TYLE_VAT_ID,
                            LOAI_ID,
                            MOTA,
                            DV_TINH
                        )
                        VALUES
                        (
                            1,
                            p_phanvung_id,
                            l_baogia_id,
                            p_lst_chitiet_khoanmuc(i).thanhTien,
                            p_lst_chitiet_khoanmuc(i).vat,
                            p_lst_chitiet_khoanmuc(i).khoanMucId,
                            l_tyle_vat,
                            l_tyle_vat_id,
                            1,
                            p_lst_chitiet_khoanmuc(i).moTa,
                            p_lst_chitiet_khoanmuc(i).donViTinh
                        );
END LOOP;
END IF;
                -- END TH PHI_KHAC

                -- TH MUA_THIET_BI
                -- Tạo ra 2 row dữ lieu trong bang CT_TIENBG
                -- row1 : khoanmuctt_id = 5 và có loai_id = 3 , id là id của bang baogia_tbi
                -- row2 : khoaanmuctt_id = 25 và có loai_id = 3, id là id của bang baogia_tbi
                IF p_lst_chitiet_khoanmuc(i).type = 'MUA_THIET_BI' THEN
                    -- INSERT BẢNG BAOGIA_TBI
                    l_baogia_tbi_id := SEQ_BAOGIA_TBI.nextval;

SELECT COUNT(*) INTO l_count FROM LOAI_TBI
WHERE LOAITBI_ID = p_lst_chitiet_khoanmuc(i).hangMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TIEN, VAT, TYLE_VAT, TYLE_VAT_ID, BLOCK_TIEP, GIA_BLOCK_TIEP, VAT_BLOCK_TIEP, BLOCK_DAU
INTO l_tien_tragop, l_vat_tragop, l_tyle_vat, l_tyle_vat_id, l_block_tiep, l_gia_block_tiep, l_vat_block_tiep, l_block_dau
FROM LOAI_TBI
WHERE LOAITBI_ID = p_lst_chitiet_khoanmuc(i).hangMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;

INSERT INTO BAOGIA_TBI
(
    BAOGIA_TBI_ID,
    PHANVUNG_ID,
    THIETBI_ID,
    BAOGIA_ID,
    SOLUONG,
    TIEN,
    VAT,
    TIEN_KM,
    VAT_KM,
    TIEN_TRATRUOC,
    VAT_TRATRUOC,
    TIEN_TRAGOP,
    VAT_TRAGOP,
    SERIAL,
    TYLE_VAT,
    TYLE_VAT_ID,
    SL_CHA,
    BLOCK_TIEP,
    GIA_BLOCK_TIEP,
    VAT_BLOCK_TIEP,
    BLOCK_DAU,
    TIEN_THUE,
    TONG_TIEN,
    TONG_THUE
)
VALUES
    (
        l_baogia_tbi_id,
        p_phanvung_id,
        p_lst_chitiet_khoanmuc(i).hangMucId,
        l_baogia_id,
        p_lst_chitiet_khoanmuc(i).soLuong,
        p_lst_chitiet_khoanmuc(i).tbTien,
        p_lst_chitiet_khoanmuc(i).tbVat,
        p_lst_chitiet_khoanmuc(i).tbTienKm,
        p_lst_chitiet_khoanmuc(i).tbVatKm,
        p_lst_chitiet_khoanmuc(i).tbTienTraTruoc,
        p_lst_chitiet_khoanmuc(i).tbVatTraTruoc,
        l_tien_tragop,
        l_vat_tragop,
        p_lst_chitiet_khoanmuc(i).tbSerial,
        l_tyle_vat,
        l_tyle_vat_id,
        p_lst_chitiet_khoanmuc(i).tbSlCha,
        l_block_tiep,
        l_gia_block_tiep,
        l_vat_block_tiep,
        l_block_dau,
        p_lst_chitiet_khoanmuc(i).tbTien + p_lst_chitiet_khoanmuc(i).tbVat,
        p_lst_chitiet_khoanmuc(i).tongTien,
        p_lst_chitiet_khoanmuc(i).vat
    );

SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 3 AND KHOANMUCTT_ID = 5 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT, TYLE_VAT_ID INTO l_tyle_vat, l_tyle_vat_id FROM KM_TT WHERE LOAI = 3 AND KHOANMUCTT_ID = 5 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
                    -- INSERT KHOANMUC 5, LOAI_ID 3
INSERT INTO CT_TIENBG
(
    ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    TIEN,
    VAT,
    KHOANMUCTT_ID,
    TYLE_VAT,
    TYLE_VAT_ID,
    LOAI_ID,
    MOTA,
    DV_TINH
)
VALUES
    (
        l_baogia_tbi_id,
        p_phanvung_id,
        l_baogia_id,
        p_lst_chitiet_khoanmuc(i).tbTien,
        p_lst_chitiet_khoanmuc(i).tbVat,
        5,
        l_tyle_vat,
        l_tyle_vat_id,
        3,
        p_lst_chitiet_khoanmuc(i).moTa,
        p_lst_chitiet_khoanmuc(i).donViTinh
    );

SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 3 AND KHOANMUCTT_ID = 25 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT, TYLE_VAT_ID INTO l_tyle_vat, l_tyle_vat_id FROM KM_TT WHERE LOAI = 3 AND KHOANMUCTT_ID = 25 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
                    -- INSERT KHOANMUC 25
INSERT INTO CT_TIENBG
(
    ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    TIEN,
    VAT,
    KHOANMUCTT_ID,
    TYLE_VAT,
    TYLE_VAT_ID,
    LOAI_ID,
    MOTA,
    DV_TINH
)
VALUES
    (
        l_baogia_tbi_id,
        p_phanvung_id,
        l_baogia_id,
        p_lst_chitiet_khoanmuc(i).tbTienKm,
        p_lst_chitiet_khoanmuc(i).tbVatKm,
        25,
        l_tyle_vat,
        l_tyle_vat_id,
        3,
        p_lst_chitiet_khoanmuc(i).moTa,
        p_lst_chitiet_khoanmuc(i).donViTinh
    );

END IF;
                -- END TH MUA_THIET_BI

                -- TH DICH_VU_CONG_THEM
                -- Insert dữ liệu bảng BAOGIA_DVGT
                -- Insert dữ liệu bảng CT_TIENBG
                IF p_lst_chitiet_khoanmuc(i).type = 'DICH_VU_CONG_THEM' THEN
                    l_baogia_dvgt_id := SEQ_BAOGIA_DVGT.nextval;

SELECT COUNT(*) INTO l_count FROM DICHVU_GT
WHERE DICHVUGT_ID = p_lst_chitiet_khoanmuc(i).hangMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT CUOC_SD, VAT_SD, BLOCK_TIEP, BLOCK_DAU, HE_SO
INTO l_cuoc_sd, l_vat_sd, l_block_tiep, l_block_dau, l_he_so
FROM DICHVU_GT
WHERE DICHVUGT_ID = p_lst_chitiet_khoanmuc(i).hangMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;

INSERT INTO BAOGIA_DVGT
(
    BG_DVGT_ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    DICHVUGT_ID,
    CUOC_LD,
    VAT_LD,
    CUOC_SD,
    VAT_SD,
    SOLUONG,
    BLOCK_TIEP,
    GIA_BLOCK_TIEP,
    VAT_BLOCK_TIEP,
    BLOCK_DAU,
    HE_SO,
    GHI_CHU
)
VALUES
    (
        l_baogia_dvgt_id,
        p_phanvung_id,
        l_baogia_id,
        p_lst_chitiet_khoanmuc(i).hangMucId,
        p_lst_chitiet_khoanmuc(i).cuocLapDat,
        p_lst_chitiet_khoanmuc(i).dvgtVatLapDat,
        l_cuoc_sd,
        l_vat_sd,
        p_lst_chitiet_khoanmuc(i).soLuong,
        l_block_tiep,
        p_lst_chitiet_khoanmuc(i).dvgtGiaBlock,
        p_lst_chitiet_khoanmuc(i).dvgtVatBlock,
        l_block_dau,
        l_he_so,
        NULL
    );

SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 2 AND KHOANMUCTT_ID = 4 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT, TYLE_VAT_ID INTO l_tyle_vat, l_tyle_vat_id FROM KM_TT WHERE LOAI = 2 AND KHOANMUCTT_ID = 4 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
                    -- INSERT KHOANMUC 4, LOAI_ID 2
INSERT INTO CT_TIENBG
(
    ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    TIEN,
    VAT,
    KHOANMUCTT_ID,
    TYLE_VAT,
    TYLE_VAT_ID,
    LOAI_ID,
    MOTA,
    DV_TINH
)
VALUES
    (
        l_baogia_dvgt_id,
        p_phanvung_id,
        l_baogia_id,
        p_lst_chitiet_khoanmuc(i).thanhTien,
        p_lst_chitiet_khoanmuc(i).vat,
        4,
        l_tyle_vat,
        l_tyle_vat_id,
        2,
        p_lst_chitiet_khoanmuc(i).moTa,
        p_lst_chitiet_khoanmuc(i).donViTinh
    );

END IF;
                -- END TH DICH_VU_CONG_THEM

                -- TH CUOC_SU_DUNG
                -- Insert dữ liệu bảng BAOGIA_GC
                -- Insert dữ liệu bảng CT_TIENBG
                -- Insert dữ liệu bảng BAOGIA_CTKM
                IF p_lst_chitiet_khoanmuc(i).type = 'CUOC_SU_DUNG' THEN
                    l_baogia_gc_id := SEQ_BAOGIA_GC.nextval;

                    IF p_lst_chitiet_khoanmuc(i).gcLoaiGoi = 2 THEN
                        l_gc_tien := p_lst_chitiet_khoanmuc(i).gcTien;
                        l_gc_vat := p_lst_chitiet_khoanmuc(i).gcVat;
END IF;

                    IF p_lst_chitiet_khoanmuc(i).gcLoaiGoi = 1 THEN
                        l_gc_tien := p_lst_chitiet_khoanmuc(i).gcMucCuocTb;
SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = 21 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT INTO l_gc_vat FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = 21 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
END IF;

INSERT INTO BAOGIA_GC
(
    BAOGIA_GC_ID,
    MUCCUOCTB_ID,
    BAOGIA_ID,
    LOAI_GOI,
    TIEN,
    VAT,
    DICHVUVT_ID,
    LOAIHINHTB_ID,
    GOI_ID,
    TOCDO_ID,
    SOLUONG
)
VALUES
    (
        l_baogia_gc_id,
        p_lst_chitiet_khoanmuc(i).phiDuyTri,
        l_baogia_id,
        p_lst_chitiet_khoanmuc(i).gcLoaiGoi,
        l_gc_tien,
        l_gc_vat,
        p_lst_chitiet_khoanmuc(i).gcDichVuVtId,
        p_lst_chitiet_khoanmuc(i).gcLoaiHinhId,
        p_lst_chitiet_khoanmuc(i).khoanMucId,
        p_lst_chitiet_khoanmuc(i).gcTocDoId,
        p_lst_chitiet_khoanmuc(i).soLuong
    );

SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = 21 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT, TYLE_VAT_ID INTO l_tyle_vat, l_tyle_vat_id FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = 21 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
                    -- INSERT KHOANMUC 21, LOAI_ID 1
INSERT INTO CT_TIENBG
(
    ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    TIEN,
    VAT,
    KHOANMUCTT_ID,
    TYLE_VAT,
    TYLE_VAT_ID,
    LOAI_ID,
    MOTA,
    DV_TINH
)
VALUES
    (
        l_baogia_gc_id,
        p_phanvung_id,
        l_baogia_id,
        p_lst_chitiet_khoanmuc(i).thanhTien,
        p_lst_chitiet_khoanmuc(i).vat,
        21,
        l_tyle_vat,
        l_tyle_vat_id,
        1,
        p_lst_chitiet_khoanmuc(i).moTa,
        p_lst_chitiet_khoanmuc(i).donViTinh
    );

IF p_lst_chitiet_khoanmuc(i).traTruoc = 1 THEN
                        INSERT INTO BAOGIA_CTKM
                        (
                            BAOGIA_GC_ID,
                            CHITIETKM_ID,
                            DATCOC_CSD,
                            TYLE_VAT,
                            BAOGIA_ID,
                            CK_TOIDA,
                            CK
                        )
                        VALUES
                        (
                            l_baogia_gc_id,
                            p_lst_chitiet_khoanmuc(i).hangMucId,
                            p_lst_chitiet_khoanmuc(i).gcTienTraTruoc,
                            p_lst_chitiet_khoanmuc(i).gcVatTraTruoc,
                            l_baogia_id,
                            p_lst_chitiet_khoanmuc(i).ckToiDa,
                            p_lst_chitiet_khoanmuc(i).ck
                        );
END IF;

END IF;
                -- END TH CUOC_SU_DUNG

END LOOP;

END IF;

        n := l_baogia_id;

OPEN l_result FOR
SELECT n AS ketqua FROM dual;

COMMIT;

EXCEPTION
          WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
OPEN l_result FOR
SELECT 0 AS ketqua FROM dual;
END;
END;

PROCEDURE SP_CAP_NHAT_BAOGIA_UPD
(
    p_baogia_id                         IN NUMBER,
    p_ma_baogia                         IN VARCHAR2,
    p_ten_baogia                        IN VARCHAR2,
    p_han_phe_duyet                     IN DATE,
    p_han_lap_dat                       IN DATE,
    p_hieu_luc_tu_ngay                  IN DATE,
    p_hieu_luc_den_ngay                 IN DATE,
    p_loai_baogia                       IN NUMBER,
    p_nhom_dichvu                       IN VARCHAR2,
    p_nguon_baogia                      IN NUMBER,
    p_nguon_baogia_id                   IN NUMBER,
    p_khachhang_id                      IN NUMBER,
    p_nguoi_lienhe                      IN VARCHAR2,
    p_sdt_lienhe                        IN VARCHAR2,
    p_email_lienhe                      IN VARCHAR2,
    p_ghi_chu                           IN VARCHAR2,
    p_lst_chitiet_khoanmuc              IN LIST_CHI_TIET_KHOANMUC,
    p_ngay_cn 				            IN DATE,
	p_nguoi_cn 				            IN VARCHAR2,
	p_may_cn 				            IN VARCHAR2,
	p_ip_cn 					        IN VARCHAR2,
    p_nhanvien_id 			            IN NUMBER,
	p_phanvung_id    		            IN NUMBER,
    p_donvi_id                          IN NUMBER,
    l_result            	            OUT SYS_REFCURSOR
)
IS
    n 			NUMBER;
    l_baogia_tbi_id NUMBER;
    l_baogia_dvgt_id NUMBER;
    l_baogia_gc_id NUMBER;
    l_tyle_vat  NUMBER NULL;
    l_tyle_vat_id   NUMBER NULL;
    l_tien_tragop NUMBER NULL;
    l_vat_tragop NUMBER NULL;
    l_block_dau NUMBER NULL;
    l_block_tiep NUMBER NULL;
    l_gia_block_tiep NUMBER NULL;
    l_vat_block_tiep NUMBER NULL;
    l_cuoc_sd NUMBER NULL;
    l_vat_sd NUMBER NULL;
    l_he_so NUMBER NULL;
    l_gc_tien NUMBER NULL;
    l_gc_vat NUMBER NULL;
    l_count NUMBER;
BEGIN
SAVEPOINT ABC;
l_tyle_vat := 0;
        l_tyle_vat_id := 0;
        l_count := 0;

UPDATE BAOGIA
SET TEN_BAOGIA              = p_ten_baogia,
    HAN_PHEDUYET            = p_han_phe_duyet,
    HAN_LAPDAT              = p_han_lap_dat,
    HIEULUC_TU              = p_hieu_luc_tu_ngay,
    HIEULUC_DEN             = p_hieu_luc_den_ngay,
    LOAIBG_ID               = p_loai_baogia,
    KHACHHANG_ID            = p_khachhang_id,
    NGUOI_LH                = p_nguoi_lienhe,
    SO_DT                   = p_sdt_lienhe,
    EMAIL                   = p_email_lienhe,
    GHICHU                  = p_ghi_chu
WHERE BAOGIA_ID = p_baogia_id AND PHANVUNG_ID = p_phanvung_id;

IF p_lst_chitiet_khoanmuc IS NOT NULL THEN

            -- Xóa dữ liệu cũ
DELETE FROM CT_TIENBG WHERE BAOGIA_ID = p_baogia_id AND PHANVUNG_ID = p_phanvung_id;
DELETE FROM BAOGIA_TBI WHERE BAOGIA_ID = p_baogia_id AND PHANVUNG_ID = p_phanvung_id;
DELETE FROM BAOGIA_DVGT WHERE BAOGIA_ID = p_baogia_id AND PHANVUNG_ID = p_phanvung_id;
DELETE FROM BAOGIA_GC WHERE BAOGIA_ID = p_baogia_id;
DELETE FROM BAOGIA_CTKM WHERE BAOGIA_ID = p_baogia_id;

FOR i IN 1..p_lst_chitiet_khoanmuc.COUNT LOOP

                -- TH PHI_KHAC
                IF p_lst_chitiet_khoanmuc(i).type = 'PHI_KHAC' THEN
                    -- Insert số lượng bản ghi = soluong input
                    -- ID=1, LOAI_ID=1
SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = p_lst_chitiet_khoanmuc(i).khoanMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT, TYLE_VAT_ID INTO l_tyle_vat, l_tyle_vat_id FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = p_lst_chitiet_khoanmuc(i).khoanMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
FOR pk IN 1..p_lst_chitiet_khoanmuc(i).soLuong LOOP
                        -- INSERT LOAI_ID 1, ID 1
                        INSERT INTO CT_TIENBG
                        (
                            ID,
                            PHANVUNG_ID,
                            BAOGIA_ID,
                            TIEN,
                            VAT,
                            KHOANMUCTT_ID,
                            TYLE_VAT,
                            TYLE_VAT_ID,
                            LOAI_ID,
                            MOTA,
                            DV_TINH
                        )
                        VALUES
                        (
                            1,
                            p_phanvung_id,
                            p_baogia_id,
                            p_lst_chitiet_khoanmuc(i).thanhTien,
                            p_lst_chitiet_khoanmuc(i).vat,
                            p_lst_chitiet_khoanmuc(i).khoanMucId,
                            l_tyle_vat,
                            l_tyle_vat_id,
                            1,
                            p_lst_chitiet_khoanmuc(i).moTa,
                            p_lst_chitiet_khoanmuc(i).donViTinh
                        );
END LOOP;
END IF;
                -- END TH PHI_KHAC

                -- TH MUA_THIET_BI
                -- Tạo ra 2 row dữ lieu trong bang CT_TIENBG
                -- row1 : khoanmuctt_id = 5 và có loai_id = 3 , id là id của bang baogia_tbi
                -- row2 : khoaanmuctt_id = 25 và có loai_id = 3, id là id của bang baogia_tbi
                IF p_lst_chitiet_khoanmuc(i).type = 'MUA_THIET_BI' THEN
                    -- INSERT BẢNG BAOGIA_TBI
                    l_baogia_tbi_id := SEQ_BAOGIA_TBI.nextval;

SELECT COUNT(*) INTO l_count FROM LOAI_TBI
WHERE LOAITBI_ID = p_lst_chitiet_khoanmuc(i).hangMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TIEN, VAT, TYLE_VAT, TYLE_VAT_ID, BLOCK_TIEP, GIA_BLOCK_TIEP, VAT_BLOCK_TIEP, BLOCK_DAU
INTO l_tien_tragop, l_vat_tragop, l_tyle_vat, l_tyle_vat_id, l_block_tiep, l_gia_block_tiep, l_vat_block_tiep, l_block_dau
FROM LOAI_TBI
WHERE LOAITBI_ID = p_lst_chitiet_khoanmuc(i).hangMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;

                    --dbms_output.put_line(l_baogia_tbi_id);
INSERT INTO BAOGIA_TBI
(
    BAOGIA_TBI_ID,
    PHANVUNG_ID,
    THIETBI_ID,
    BAOGIA_ID,
    SOLUONG,
    TIEN,
    VAT,
    TIEN_KM,
    VAT_KM,
    TIEN_TRATRUOC,
    VAT_TRATRUOC,
    TIEN_TRAGOP,
    VAT_TRAGOP,
    SERIAL,
    TYLE_VAT,
    TYLE_VAT_ID,
    SL_CHA,
    BLOCK_TIEP,
    GIA_BLOCK_TIEP,
    VAT_BLOCK_TIEP,
    BLOCK_DAU,
    TIEN_THUE,
    TONG_TIEN,
    TONG_THUE
)
VALUES
    (
        l_baogia_tbi_id,
        p_phanvung_id,
        p_lst_chitiet_khoanmuc(i).hangMucId,
        p_baogia_id,
        p_lst_chitiet_khoanmuc(i).soLuong,
        p_lst_chitiet_khoanmuc(i).tbTien,
        p_lst_chitiet_khoanmuc(i).tbVat,
        p_lst_chitiet_khoanmuc(i).tbTienKm,
        p_lst_chitiet_khoanmuc(i).tbVatKm,
        p_lst_chitiet_khoanmuc(i).tbTienTraTruoc,
        p_lst_chitiet_khoanmuc(i).tbVatTraTruoc,
        l_tien_tragop,
        l_vat_tragop,
        p_lst_chitiet_khoanmuc(i).tbSerial,
        l_tyle_vat,
        l_tyle_vat_id,
        p_lst_chitiet_khoanmuc(i).tbSlCha,
        l_block_tiep,
        l_gia_block_tiep,
        l_vat_block_tiep,
        l_block_dau,
        p_lst_chitiet_khoanmuc(i).tbTien + p_lst_chitiet_khoanmuc(i).tbVat,
        p_lst_chitiet_khoanmuc(i).tongTien,
        p_lst_chitiet_khoanmuc(i).vat
    );

--dbms_output.put_line('K1');

SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 3 AND KHOANMUCTT_ID = 5 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT, TYLE_VAT_ID INTO l_tyle_vat, l_tyle_vat_id FROM KM_TT WHERE LOAI = 3 AND KHOANMUCTT_ID = 5 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
                    -- INSERT KHOANMUC 5, LOAI_ID 3
INSERT INTO CT_TIENBG
(
    ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    TIEN,
    VAT,
    KHOANMUCTT_ID,
    TYLE_VAT,
    TYLE_VAT_ID,
    LOAI_ID,
    MOTA,
    DV_TINH
)
VALUES
    (
        l_baogia_tbi_id,
        p_phanvung_id,
        p_baogia_id,
        p_lst_chitiet_khoanmuc(i).tbTien,
        p_lst_chitiet_khoanmuc(i).tbVat,
        5,
        l_tyle_vat,
        l_tyle_vat_id,
        3,
        p_lst_chitiet_khoanmuc(i).moTa,
        p_lst_chitiet_khoanmuc(i).donViTinh
    );

SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 3 AND KHOANMUCTT_ID = 25 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT, TYLE_VAT_ID INTO l_tyle_vat, l_tyle_vat_id FROM KM_TT WHERE LOAI = 3 AND KHOANMUCTT_ID = 25 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
                    -- INSERT KHOANMUC 25
INSERT INTO CT_TIENBG
(
    ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    TIEN,
    VAT,
    KHOANMUCTT_ID,
    TYLE_VAT,
    TYLE_VAT_ID,
    LOAI_ID,
    MOTA,
    DV_TINH
)
VALUES
    (
        l_baogia_tbi_id,
        p_phanvung_id,
        p_baogia_id,
        p_lst_chitiet_khoanmuc(i).tbTien,
        p_lst_chitiet_khoanmuc(i).tbVat,
        25,
        l_tyle_vat,
        l_tyle_vat_id,
        3,
        p_lst_chitiet_khoanmuc(i).moTa,
        p_lst_chitiet_khoanmuc(i).donViTinh
    );

END IF;
                -- END TH MUA_THIET_BI

                -- TH DICH_VU_CONG_THEM
                -- Insert dữ liệu bảng BAOGIA_DVGT
                -- Insert dữ liệu bảng CT_TIENBG
                IF p_lst_chitiet_khoanmuc(i).type = 'DICH_VU_CONG_THEM' THEN
                    l_baogia_dvgt_id := SEQ_BAOGIA_DVGT.nextval;

SELECT COUNT(*) INTO l_count FROM DICHVU_GT
WHERE DICHVUGT_ID = p_lst_chitiet_khoanmuc(i).hangMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT CUOC_SD, VAT_SD, BLOCK_TIEP, BLOCK_DAU, HE_SO
INTO l_cuoc_sd, l_vat_sd, l_block_tiep, l_block_dau, l_he_so
FROM DICHVU_GT
WHERE DICHVUGT_ID = p_lst_chitiet_khoanmuc(i).hangMucId AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;

INSERT INTO BAOGIA_DVGT
(
    BG_DVGT_ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    DICHVUGT_ID,
    CUOC_LD,
    VAT_LD,
    CUOC_SD,
    VAT_SD,
    SOLUONG,
    BLOCK_TIEP,
    GIA_BLOCK_TIEP,
    VAT_BLOCK_TIEP,
    BLOCK_DAU,
    HE_SO,
    GHI_CHU
)
VALUES
    (
        l_baogia_dvgt_id,
        p_phanvung_id,
        p_baogia_id,
        p_lst_chitiet_khoanmuc(i).hangMucId,
        p_lst_chitiet_khoanmuc(i).cuocLapDat,
        p_lst_chitiet_khoanmuc(i).dvgtVatLapDat,
        l_cuoc_sd,
        l_vat_sd,
        p_lst_chitiet_khoanmuc(i).soLuong,
        l_block_tiep,
        p_lst_chitiet_khoanmuc(i).dvgtGiaBlock,
        p_lst_chitiet_khoanmuc(i).dvgtVatBlock,
        l_block_dau,
        l_he_so,
        NULL
    );

SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 2 AND KHOANMUCTT_ID = 4 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT, TYLE_VAT_ID INTO l_tyle_vat, l_tyle_vat_id FROM KM_TT WHERE LOAI = 2 AND KHOANMUCTT_ID = 4 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
                    -- INSERT KHOANMUC 4, LOAI_ID 2
INSERT INTO CT_TIENBG
(
    ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    TIEN,
    VAT,
    KHOANMUCTT_ID,
    TYLE_VAT,
    TYLE_VAT_ID,
    LOAI_ID,
    MOTA,
    DV_TINH
)
VALUES
    (
        l_baogia_dvgt_id,
        p_phanvung_id,
        p_baogia_id,
        p_lst_chitiet_khoanmuc(i).thanhTien,
        p_lst_chitiet_khoanmuc(i).vat,
        4,
        l_tyle_vat,
        l_tyle_vat_id,
        2,
        p_lst_chitiet_khoanmuc(i).moTa,
        p_lst_chitiet_khoanmuc(i).donViTinh
    );

END IF;
                -- END TH DICH_VU_CONG_THEM

                -- TH CUOC_SU_DUNG
                -- Insert dữ liệu bảng BAOGIA_GC
                -- Insert dữ liệu bảng CT_TIENBG
                -- Insert dữ liệu bảng BAOGIA_CTKM
                IF p_lst_chitiet_khoanmuc(i).type = 'CUOC_SU_DUNG' THEN
                    l_baogia_gc_id := SEQ_BAOGIA_GC.nextval;

                    IF p_lst_chitiet_khoanmuc(i).gcLoaiGoi = 2 THEN
                        l_gc_tien := p_lst_chitiet_khoanmuc(i).gcTien;
                        l_gc_vat := p_lst_chitiet_khoanmuc(i).gcVat;
END IF;

                  IF p_lst_chitiet_khoanmuc(i).gcLoaiGoi = 1 THEN
                        l_gc_tien := p_lst_chitiet_khoanmuc(i).gcMucCuocTb;
SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = 21 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT INTO l_gc_vat FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = 21 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
END IF;

INSERT INTO BAOGIA_GC
(
    BAOGIA_GC_ID,
    MUCCUOCTB_ID,
    BAOGIA_ID,
    LOAI_GOI,
    TIEN,
    VAT,
    DICHVUVT_ID,
    LOAIHINHTB_ID,
    GOI_ID,
    TOCDO_ID,
    SOLUONG
)
VALUES
    (
        l_baogia_gc_id,
        p_lst_chitiet_khoanmuc(i).phiDuyTri,
        p_baogia_id,
        p_lst_chitiet_khoanmuc(i).gcLoaiGoi,
        l_gc_tien,
        l_gc_vat,
        p_lst_chitiet_khoanmuc(i).gcDichVuVtId,
        p_lst_chitiet_khoanmuc(i).gcLoaiHinhId,
        p_lst_chitiet_khoanmuc(i).khoanMucId,
        p_lst_chitiet_khoanmuc(i).gcTocDoId,
        p_lst_chitiet_khoanmuc(i).soLuong
    );

SELECT COUNT(*) INTO l_count FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = 21 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
IF l_count > 0 THEN
SELECT TYLE_VAT, TYLE_VAT_ID INTO l_tyle_vat, l_tyle_vat_id FROM KM_TT WHERE LOAI = 1 AND KHOANMUCTT_ID = 21 AND ROWNUM = 1 AND PHANVUNG_ID = p_phanvung_id;
END IF;
                    -- INSERT KHOANMUC 21, LOAI_ID 1
INSERT INTO CT_TIENBG
(
    ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    TIEN,
    VAT,
    KHOANMUCTT_ID,
    TYLE_VAT,
    TYLE_VAT_ID,
    LOAI_ID,
    MOTA,
    DV_TINH
)
VALUES
    (
        l_baogia_gc_id,
        p_phanvung_id,
        p_baogia_id,
        p_lst_chitiet_khoanmuc(i).thanhTien,
        p_lst_chitiet_khoanmuc(i).vat,
        21,
        l_tyle_vat,
        l_tyle_vat_id,
        1,
        p_lst_chitiet_khoanmuc(i).moTa,
        p_lst_chitiet_khoanmuc(i).donViTinh
    );

IF p_lst_chitiet_khoanmuc(i).traTruoc = 1 THEN
                        INSERT INTO BAOGIA_CTKM
                        (
                            BAOGIA_GC_ID,
                            CHITIETKM_ID,
                            DATCOC_CSD,
                            TYLE_VAT,
                            BAOGIA_ID,
                            CK_TOIDA,
                            CK
                        )
                        VALUES
                        (
                            l_baogia_gc_id,
                            p_lst_chitiet_khoanmuc(i).hangMucId,
                            p_lst_chitiet_khoanmuc(i).gcTienTraTruoc,
                            p_lst_chitiet_khoanmuc(i).gcVatTraTruoc,
                            p_baogia_id,
                            p_lst_chitiet_khoanmuc(i).ckToiDa,
                            p_lst_chitiet_khoanmuc(i).ck
                        );
END IF;

END IF;
                -- END TH CUOC_SU_DUNG

END LOOP;

END IF;

        n := SQL%ROWCOUNT;

OPEN l_result FOR
SELECT n AS ketqua FROM dual;

COMMIT;

EXCEPTION
          WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
OPEN l_result FOR
SELECT 0 AS ketqua FROM dual;
END;
END;

-- api 28
PROCEDURE SP_GET_TRACUU_THONGTIN_KEHOACH_TC_SEL (
    p_loai_nhiem_vu IN VARCHAR2,
    p_ten_chuong_trinh IN VARCHAR2,
    p_tu_ngay IN DATE,
    p_den_ngay IN DATE,
    p_pn_page_id IN NUMBER,
    p_pn_rec_per_page IN NUMBER,
    p_nhan_vien_id IN NUMBER,
    p_phanvung_id IN NUMBER,
    v_cusor     OUT SYS_REFCURSOR,
    v_total     OUT number)
IS
    l_result      SYS_REFCURSOR;
    l_sql         VARCHAR2(20000);
BEGIN
    --Lay thong tin danh sach nhan vien
BEGIN

        -------p_loai_chuong_trinh = 'CTBH'
        IF p_loai_nhiem_vu = 'CTBH' THEN
            l_sql := 'SELECT TO_CHAR(tk.NGAY_TC, ''DD/MM/YYYY'') ngayTiepCan,';
            l_sql := l_sql || 'taodl_tc.MA_NV maNhiemVu,';
            l_sql := l_sql || 'kh.MA_KH maKhachHang,';
            l_sql := l_sql || 'kh.TEN_KH tenKhachHang,';
            l_sql := l_sql || 'kh.DIACHI_KH diaChiKhachHang,';
            l_sql := l_sql || 'tk.NGUOI_LH nguoiLienHe,';
            l_sql := l_sql || 'tk.SDT_LH soDienThoaiLienHe,';
            l_sql := l_sql || 'tk.EMAIL_LH emailLienHe,';
            l_sql := l_sql || 'tk.HINHTHUC htTiepCan,';
            l_sql := l_sql || 'dichvu_vt.TEN_DVVT tenDichVu,';
            l_sql := l_sql || 'loaihinh_tb.LOAIHINH_TB tenLoaiHinh,';
            l_sql := l_sql || 'vat_pham.TEN_VAT_PHAM vatPhamCS,';
            l_sql := l_sql || 'tk.NOIDUNG noiDungTC ';


            l_sql := l_sql || ' from ctbh_temp ct
                                join TIEPCAN_KH tk on ct.ma_ct=tk.MA_CT ';

            l_sql := l_sql || 'LEFT JOIN taodl_tc ON (taodl_tc.LANTAO_ID = tk.LANTAO_ID and taodl_tc.phanvung_id = tk.PHANVUNG_ID)  ';
            l_sql := l_sql || 'INNER JOIN taodl_tckh ON taodl_tc.LANTAO_ID = taodl_tckh.LANTAO_ID ';
            l_sql := l_sql || 'INNER JOIN db_khachhang kh ON kh.KHACHHANG_ID = taodl_tckh.KHACHHANG_ID ';
            l_sql := l_sql || 'LEFT JOIN dichvu_vt ON taodl_tc.DICHVUVT_ID = dichvu_vt.DICHVUVT_ID ';
            l_sql := l_sql || 'LEFT JOIN loaihinh_tb ON taodl_tc.LOAITB_ID = loaihinh_tb.LOAITB_ID ';
            l_sql := l_sql || 'LEFT JOIN vat_pham_tckh ON tk.TIEPCAN_ID = vat_pham_tckh.TIEPCAN_ID ';
            l_sql := l_sql || 'LEFT JOIN vat_pham ON vat_pham.VAT_PHAM_ID = vat_pham_tckh.VATPHAM_ID ';
            l_sql := l_sql || 'WHERE 1 = 1 and kh.KHACHHANG_ID = tk.KHACHHANG_ID AND ct.loai_ct = ''CTBH'' ';
            l_sql := l_sql || ' and tk.PHANVUNG_ID = ' || p_phanvung_id;
            l_sql := l_sql || ' and taodl_tckh.PHANVUNG_ID = ' || p_phanvung_id;
            l_sql := l_sql || ' and kh.PHANVUNG_ID = ' || p_phanvung_id;

            IF p_nhan_vien_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.NHANVIEN_ID = ' || p_nhan_vien_id;
END IF;

            IF p_tu_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_ten_chuong_trinh IS NOT NULL THEN
            l_sql := l_sql || ' and ct.ten_ct LIKE ''%' || p_ten_chuong_trinh || '%''';
END IF;

            l_sql := l_sql || ' ORDER BY tk.ngay_cn DESC';
END IF;

        -----------p_loai_chuong_trinh = 'CTCSKH'

        IF p_loai_nhiem_vu = 'CTCSKH' THEN
            l_sql := 'SELECT TO_CHAR(tk.NGAY_TC, ''DD/MM/YYYY'') ngayTiepCan,';
            l_sql := l_sql || 'taodl_tc.MA_NV maNhiemVu,';
            l_sql := l_sql || 'kh.MA_KH maKhachHang,';
            l_sql := l_sql || 'kh.TEN_KH tenKhachHang,';
            l_sql := l_sql || 'kh.DIACHI_KH diaChiKhachHang,';
            l_sql := l_sql || 'tk.NGUOI_LH nguoiLienHe,';
            l_sql := l_sql || 'tk.SDT_LH soDienThoaiLienHe,';
            l_sql := l_sql || 'tk.EMAIL_LH emailLienHe,';
            l_sql := l_sql || 'tk.HINHTHUC htTiepCan,';
            l_sql := l_sql || 'dichvu_vt.TEN_DVVT tenDichVu,';
            l_sql := l_sql || 'loaihinh_tb.LOAIHINH_TB tenLoaiHinh,';
            l_sql := l_sql || 'vat_pham.TEN_VAT_PHAM vatPhamCS,';
            l_sql := l_sql || 'tk.NOIDUNG noiDungTC ';

            l_sql := l_sql || ' from CTCSKH_temp ct
                     join TIEPCAN_KH tk on ct.ma_ct=tk.MA_CT ';

            l_sql := l_sql || 'LEFT JOIN taodl_tc ON (taodl_tc.LANTAO_ID = tk.LANTAO_ID and taodl_tc.phanvung_id = tk.PHANVUNG_ID) ';
            l_sql := l_sql || 'INNER JOIN taodl_tckh ON taodl_tc.LANTAO_ID = taodl_tckh.LANTAO_ID ';
            l_sql := l_sql || 'INNER JOIN db_khachhang kh ON kh.KHACHHANG_ID = taodl_tckh.KHACHHANG_ID ';
            l_sql := l_sql || 'LEFT JOIN dichvu_vt ON taodl_tc.DICHVUVT_ID = dichvu_vt.DICHVUVT_ID ';
            l_sql := l_sql || 'LEFT JOIN loaihinh_tb ON taodl_tc.LOAITB_ID = loaihinh_tb.LOAITB_ID ';
            l_sql := l_sql || 'LEFT JOIN vat_pham_tckh ON tk.TIEPCAN_ID = vat_pham_tckh.TIEPCAN_ID ';
            l_sql := l_sql || 'LEFT JOIN vat_pham ON vat_pham.VAT_PHAM_ID = vat_pham_tckh.VATPHAM_ID ';
            l_sql := l_sql || 'WHERE 1 = 1 and kh.KHACHHANG_ID = tk.KHACHHANG_ID AND ct.loai_ct = ''CTCSKH'' ';
            l_sql := l_sql || ' and tk.PHANVUNG_ID = ' || p_phanvung_id;
            l_sql := l_sql || ' and taodl_tckh.PHANVUNG_ID = ' || p_phanvung_id;
            l_sql := l_sql || ' and kh.PHANVUNG_ID = ' || p_phanvung_id;

            IF p_nhan_vien_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tk.NHANVIEN_ID = ' || p_nhan_vien_id;
END IF;

            IF p_tu_ngay IS NOT NULL THEN
            l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tk.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_ten_chuong_trinh IS NOT NULL THEN
            l_sql := l_sql || ' and ct.ten_ct LIKE ''%' || p_ten_chuong_trinh || '%''';
END IF;

            l_sql := l_sql || ' ORDER BY tk.ngay_cn DESC';
END IF;
       -----------   p_loai_chuong_trinh = 'KHTN'
        IF p_loai_nhiem_vu = 'KHTN' THEN
            l_sql := 'SELECT TO_CHAR(tiepcan_kh.NGAY_TC, ''DD/MM/YYYY'') ngayTiepCan,';
            l_sql := l_sql || 'taodl_tc.MA_NV maNhiemVu,';
            l_sql := l_sql || 'kh.MA_KH maKhachHang,';
            l_sql := l_sql || 'kh.TEN_KH tenKhachHang,';
            l_sql := l_sql || 'kh.DIACHI_KH diaChiKhachHang,';
            l_sql := l_sql || 'tiepcan_kh.NGUOI_LH nguoiLienHe,';
            l_sql := l_sql || 'tiepcan_kh.SDT_LH soDienThoaiLienHe,';
            l_sql := l_sql || 'tiepcan_kh.EMAIL_LH emailLienHe,';
            l_sql := l_sql || 'tiepcan_kh.HINHTHUC htTiepCan,';
            l_sql := l_sql || 'dichvu_vt.TEN_DVVT tenDichVu,';
            l_sql := l_sql || 'loaihinh_tb.LOAIHINH_TB tenLoaiHinh,';
            l_sql := l_sql || 'vat_pham.TEN_VAT_PHAM vatPhamCS,';
            l_sql := l_sql || 'tiepcan_kh.NOIDUNG noiDungTC ';

            l_sql := l_sql || 'FROM tiepcan_kh ';
            l_sql := l_sql || 'LEFT JOIN taodl_tc ON (taodl_tc.LANTAO_ID = tiepcan_kh.LANTAO_ID and taodl_tc.phanvung_id = tiepcan_kh.PHANVUNG_ID)';
            l_sql := l_sql || 'INNER JOIN taodl_tckh ON taodl_tc.LANTAO_ID = taodl_tckh.LANTAO_ID ';
            l_sql := l_sql || 'INNER JOIN db_khachhang kh ON kh.KHACHHANG_ID = taodl_tckh.KHACHHANG_ID ';
            l_sql := l_sql || 'LEFT JOIN dichvu_vt ON taodl_tc.DICHVUVT_ID = dichvu_vt.DICHVUVT_ID ';
            l_sql := l_sql || 'LEFT JOIN loaihinh_tb ON taodl_tc.LOAITB_ID = loaihinh_tb.LOAITB_ID ';
            l_sql := l_sql || 'LEFT JOIN vat_pham_tckh ON tiepcan_kh.TIEPCAN_ID = vat_pham_tckh.TIEPCAN_ID ';
            l_sql := l_sql || 'LEFT JOIN vat_pham ON vat_pham.VAT_PHAM_ID = vat_pham_tckh.VATPHAM_ID ';
            l_sql := l_sql || 'WHERE 1 = 1 and kh.KHACHHANG_ID = tiepcan_kh.KHACHHANG_ID';
            l_sql := l_sql || ' and tiepcan_kh.PHANVUNG_ID = ' || p_phanvung_id;
            l_sql := l_sql || ' and taodl_tckh.PHANVUNG_ID = ' || p_phanvung_id;
            l_sql := l_sql || ' and kh.PHANVUNG_ID = ' || p_phanvung_id;
            IF p_nhan_vien_id IS NOT NULL THEN
                 l_sql := l_sql || ' AND tiepcan_kh.NHANVIEN_ID = ' || p_nhan_vien_id;
END IF;

            IF p_tu_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tiepcan_kh.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

            IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(tiepcan_kh.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

            l_sql := l_sql || ' ORDER BY tiepcan_kh.ngay_cn DESC';
END IF;


    --lay count data truoc khi qua phan trang
        dbms_output.put_line(v_total);
        v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);
--lay data cusor sau phan trang
        dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;


EXCEPTION
        WHEN OTHERS THEN
BEGIN
            --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                 || sqlerrm
                                 || ')'' name from dual';
v_total := 0;
            v_cusor := l_result;

END;
END;
END;

PROCEDURE SP_TAO_FILE_INFO_INS
(
    p_baogia_id                         IN NUMBER,
    p_ghi_chu                           IN VARCHAR2,
    p_lst_file_info                     IN LIST_FILE_INFO,
    p_ngay_cn 				            IN DATE,
	p_nguoi_cn 				            IN VARCHAR2,
	p_may_cn 				            IN VARCHAR2,
	p_ip_cn 					        IN VARCHAR2,
	p_phanvung_id    		            IN NUMBER,
    l_result            	            OUT SYS_REFCURSOR
)
IS
    n 			NUMBER;
    l_file_id   NUMBER;
    l_ghi_chu_file VARCHAR2(300);
BEGIN
SAVEPOINT ABC;

-- Xóa thông tin file cũ
DELETE FROM ADMIN.FILE_HS WHERE FILE_ID IN (SELECT FILEHS_ID FROM ADMIN.HS_BAOGIA WHERE BAOGIA_ID = p_baogia_id) AND PHANVUNG_ID = p_phanvung_id;
DELETE FROM ADMIN.HS_BAOGIA WHERE BAOGIA_ID = p_baogia_id;


FOR i IN 1..p_lst_file_info.COUNT LOOP

        --DBMS_OUTPUT.PUT_LINE(p_lst_file_info(i).fileName);
        --DBMS_OUTPUT.PUT_LINE(p_lst_file_info(i).urlFile);

        l_file_id := ADMIN.SEQ_FILE_HS.nextval;

        IF p_ghi_chu IS NOT NULL THEN
            l_ghi_chu_file := p_ghi_chu;
ELSE
            l_ghi_chu_file := p_lst_file_info(i).ghiChuFile;
END IF;

        --DBMS_OUTPUT.PUT_LINE(l_file_id);

        -- INSERT FILE_HS
INSERT INTO ADMIN.FILE_HS
(
    PHANVUNG_ID,
    FILE_ID,
    LOAIFILE_ID,
    URL,
    TRANGTHAIHS_ID,
    GHICHU,
    MAY_CN,
    NGAY_CN,
    NGUOI_CN,
    IP_CN,
    TEN_FILE,
    KIEUFILE_ID
)
VALUES
    (
        p_phanvung_id,
        l_file_id,
        12,
        p_lst_file_info(i).urlFile,
        1,
        l_ghi_chu_file,
        p_may_cn,
        p_ngay_cn,
        p_nguoi_cn,
        p_ip_cn,
        p_lst_file_info(i).fileName,
        1
    );

--DBMS_OUTPUT.PUT_LINE('HS_BAOGIA');
-- INSERT HS_BAOGIA
INSERT INTO ADMIN.HS_BAOGIA
(
    BAOGIA_ID,
    FILEHS_ID
)
VALUES
    (
        p_baogia_id,
        l_file_id
    );

--DBMS_OUTPUT.PUT_LINE('HS_BAOGIA-end');

END LOOP;

    n := SQL%ROWCOUNT;

OPEN l_result FOR
SELECT n AS ketqua FROM dual;

COMMIT;

EXCEPTION
      WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
OPEN l_result FOR
SELECT 0 AS ketqua FROM dual;
END;
END;
-- api 55
FUNCTION FN_APPROVAL_BAO_GIA_CHK(
	p_bao_gia_id_lst IN LIST_NUMBER,
    p_url           IN VARCHAR2,
    p_phanvung_id   IN NUMBER,
    p_nhanvien_id   IN NUMBER,
    p_donvi_id   IN NUMBER,
    p_may_cn        IN VARCHAR2,
    p_nguoi_cn      IN VARCHAR2,
    p_ip_cn         IN VARCHAR2,
    p_ngay_cn	    IN DATE)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_count_record NUMBER;
    l_so_dt VARCHAR2(20);
    l_noidung VARCHAR2(2000);
    l_ghichu VARCHAR2(2000);
    l_id_baogia VARCHAR2(2000);
    l_ma_baogia VARCHAR2(2000);
    l_huonggiao_id NUMBER;
BEGIN
BEGIN
SAVEPOINT ABC;
--get danh sach id bao gia
SELECT count(BAOGIA_ID) INTO l_count_record
FROM BAOGIA
WHERE BAOGIA_ID member of p_bao_gia_id_lst
                 AND BAOGIA.TTBG_ID IN (1)
                 AND BAOGIA.PHANVUNG_ID = p_phanvung_id;

IF l_count_record = p_bao_gia_id_lst.COUNT THEN

select HUONGGIAO_ID INTO l_huonggiao_id from huonggiao where quytrinh_id in
                                                             (select quytrinh_id from Quytrinh where nhom_qt_id=11)
                                                         and phanvung_id= p_phanvung_id and thutu=2;
-- call sms
l_ghichu := 'Nhắn tin từ nghiệp vụ Gửi phê duyệt báo giá khách hàng';
FOR sms in (select BAOGIA_ID, MA_BAOGIA, HAN_PHEDUYET, TEN_BAOGIA
                        from BAOGIA WHERE BAOGIA_ID member of p_bao_gia_id_lst AND PHANVUNG_ID = p_phanvung_id)
            LOOP
            --   -- gửi phê duyệt
UPDATE BAOGIA
SET BAOGIA.TTBG_ID = 5
WHERE BAOGIA.BAOGIA_ID = sms.BAOGIA_ID AND PHANVUNG_ID = p_phanvung_id;

SELECT nhanvien.so_dt INTO l_so_dt
FROM admin.nhanvien
         JOIN BAOGIA ON (nhanvien.nhanvien_id = BAOGIA.nhanvien_id AND nhanvien.DONVI_ID = BAOGIA.DONVI_ID)
         JOIN admin.NHANVIEN_LNV ON nhanvien.nhanvien_id = NHANVIEN_LNV.nhanvien_id
WHERE BAOGIA.BAOGIA_ID = sms.BAOGIA_ID and NHANVIEN_LNV.loainv_id = 104 and rownum = 1
  AND BAOGIA.PHANVUNG_ID = p_phanvung_id
  and admin.nhanvien.phanvung_id = p_phanvung_id;

l_noidung := 'Báo giá cần phê duyệt : ' || sms.MA_BAOGIA || ' ' || sms.TEN_BAOGIA || ' ' || sms.HAN_PHEDUYET || ' ' || p_url;

            send_sms(p_phanvung_id, l_so_dt, l_noidung, l_ghichu, p_may_cn, p_nguoi_cn, p_ip_cn);

            -- insert lịch sử báo giá GP
                    PKG_OS_TCKH.SP_INSERT_UPDATE_BAO_GIA_GP(
                            sms.BAOGIA_ID,
                            p_phanvung_id,
                            p_ngay_cn,
                            null,
                            0,
                            0,
                            p_donvi_id,
                            p_nhanvien_id,
                            1,
                            null,
                            0,
                            0,
                            0,
                            p_may_cn,
                            p_nguoi_cn,
                            p_ip_cn,
                            p_ngay_cn,
                            l_huonggiao_id
                        );
END LOOP;
            l_result := 'TRUE';
ELSE
         FOR abc in (select MA_BAOGIA from BAOGIA WHERE PHANVUNG_ID = p_phanvung_id AND BAOGIA_ID member of p_bao_gia_id_lst AND PHANVUNG_ID = p_phanvung_id)

            LOOP l_ma_baogia := l_ma_baogia || ', ' || abc.MA_BAOGIA;
END LOOP;
            l_ma_baogia := RTRIM(SUBSTR(l_ma_baogia,2,LENGTH(l_ma_baogia) ));
            l_result := 'Các mã báo giá sau : ' || l_ma_baogia ||' không hợp lệ! vui lòng kiểm tra lại';
END IF;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
--                    l_result := 'FALSE';
l_result := 'Co Loi xay ra ' ||sqlerrm;
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;
----------------------------------------------------------
-- api 58
FUNCTION FN_GUI_THAM_DINH_CHK(
	p_bao_gia_id_lst IN LIST_NUMBER,
    p_url           IN VARCHAR2,
    p_phanvung_id   IN NUMBER,
    p_nhanvien_id   IN NUMBER,
    p_donvi_id   IN NUMBER,
    p_may_cn        IN VARCHAR2,
    p_nguoi_cn      IN VARCHAR2,
    p_ip_cn         IN VARCHAR2,
    p_ngay_cn	    IN DATE,
    p_ngay_giao     IN DATE,
    p_donvi_giao    IN NUMBER,
    p_nguoi_giao    IN NUMBER,
    p_donvi_nhan    IN NUMBER,
    p_nguoi_nhan    IN NUMBER,
    p_noi_dung      IN VARCHAR2,
    p_menu_id       IN NUMBER)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_so_dt VARCHAR2(20);
    l_count_record NUMBER;
    l_noidung_vuot_cap VARCHAR2(200);
    l_noidung VARCHAR2(200);
    l_ghichu VARCHAR2(200);
    l_huonggiao_id NUMBER;
    l_ma_baogia VARCHAR2(2000);
BEGIN
BEGIN
SAVEPOINT ABC;
--get danh sach id bao gia
SELECT count(BAOGIA_ID) INTO l_count_record
FROM BAOGIA
WHERE BAOGIA_ID member of p_bao_gia_id_lst
                 AND (BAOGIA.TTBG_ID = 1 OR (BAOGIA.TTBG_ID = 5 AND BAOGIA.LOAIBG_ID = 1))
                 AND baogia.phanvung_id = p_phanvung_id;
-- gửi tham dinh
IF l_count_record = p_bao_gia_id_lst.COUNT THEN
select HUONGGIAO_ID INTO l_huonggiao_id from huonggiao where quytrinh_id in
                                                             (select quytrinh_id from Quytrinh where nhom_qt_id=11)
                                                         and phanvung_id= p_phanvung_id and thutu=1;

l_ghichu := 'Nhắn tin từ nghiệp vụ Gửi thẩm định báo giá khách hàng';

FOR sms in (select BAOGIA_ID, MA_BAOGIA, HAN_PHEDUYET, TEN_BAOGIA, LOAIBG_ID, TTBG_ID from BAOGIA WHERE PHANVUNG_ID = p_phanvung_id and BAOGIA_ID member of p_bao_gia_id_lst)
            LOOP
            -- update gui tham dinh noi bo
                IF sms.TTBG_ID = 4 AND sms.LOAIBG_ID = 1 THEN

UPDATE BAOGIA
SET BAOGIA.TTBG_ID = 3
WHERE BAOGIA.BAOGIA_ID = sms.BAOGIA_ID
  and baogia.phanvung_id = p_phanvung_id;
-- lay so dt gui sms
SELECT nhanvien.so_dt INTO l_so_dt
FROM admin.nhanvien
         JOIN BAOGIA ON (nhanvien.nhanvien_id = BAOGIA.nhanvien_id AND nhanvien.DONVI_ID = BAOGIA.DONVI_ID)
         JOIN admin.NHANVIEN_LNV ON nhanvien.nhanvien_id = NHANVIEN_LNV.nhanvien_id
WHERE BAOGIA.BAOGIA_ID = sms.BAOGIA_ID and NHANVIEN_LNV.loainv_id = 104 and rownum = 1
  AND baogia.phanvung_id = p_phanvung_id
  AND nhanvien.phanvung_id = p_phanvung_id  ;

l_noidung := 'Báo giá cần gửi thẩm định nội bộ : ' || sms.MA_BAOGIA || ' ' || sms.TEN_BAOGIA || ' ' || sms.HAN_PHEDUYET || ' ' || p_url;

                    send_sms(p_phanvung_id, l_so_dt, l_noidung, l_ghichu, p_may_cn, p_nguoi_cn, p_ip_cn);

select HUONGGIAO_ID INTO l_huonggiao_id from huonggiao where quytrinh_id in
                                                             (select quytrinh_id from Quytrinh where nhom_qt_id=11)
                                                         and phanvung_id= p_phanvung_id and thutu=3;
-- insert lịch sử báo giá GP
PKG_OS_TCKH.SP_INSERT_UPDATE_BAO_GIA_GP(
                            sms.BAOGIA_ID,
                            p_phanvung_id,
                            p_ngay_cn,
                            null,
                            0,
                            0,
                            p_donvi_id,
                            p_nhanvien_id,
                            1,
                            null,
                            0,
                            0,
                            0,
                            p_may_cn,
                            p_nguoi_cn,
                            p_ip_cn,
                            p_ngay_cn,
                            l_huonggiao_id
                        );

                -- update gui tham dinh noi bo
ELSE IF sms.LOAIBG_ID = 1 THEN

UPDATE BAOGIA
SET BAOGIA.TTBG_ID = 3
WHERE BAOGIA.BAOGIA_ID = sms.BAOGIA_ID
  and baogia.phanvung_id = p_phanvung_id;
-- lay so dt gui sms
SELECT nhanvien.so_dt INTO l_so_dt
FROM admin.nhanvien
         JOIN BAOGIA ON (nhanvien.nhanvien_id = BAOGIA.nhanvien_id AND nhanvien.DONVI_ID = BAOGIA.DONVI_ID)
         JOIN admin.NHANVIEN_LNV ON nhanvien.nhanvien_id = NHANVIEN_LNV.nhanvien_id
WHERE BAOGIA.BAOGIA_ID = sms.BAOGIA_ID and NHANVIEN_LNV.loainv_id = 104  and rownum = 1
  AND baogia.phanvung_id = p_phanvung_id
  AND nhanvien.phanvung_id = p_phanvung_id;

l_noidung := 'Báo giá cần gửi thẩm định nội bộ : ' || sms.MA_BAOGIA || ' ' || sms.TEN_BAOGIA || ' ' || sms.HAN_PHEDUYET || ' ' || p_url;

                    send_sms(p_phanvung_id, l_so_dt, l_noidung, l_ghichu, p_may_cn, p_nguoi_cn, p_ip_cn);

                    -- insert lịch sử báo giá GP
                        PKG_OS_TCKH.SP_INSERT_UPDATE_BAO_GIA_GP(
                            sms.BAOGIA_ID,
                            p_phanvung_id,
                            p_ngay_cn,
                            null,
                            0,
                            0,
                            p_donvi_id,
                            p_nhanvien_id,
                            1,
                            null,
                            0,
                            0,
                            0,
                            p_may_cn,
                            p_nguoi_cn,
                            p_ip_cn,
                            p_ngay_cn,
                            l_huonggiao_id
                        );

                -- update gui tham dinh vuot cap
ELSE IF sms.LOAIBG_ID = 3 or sms.LOAIBG_ID = 4 or sms.LOAIBG_ID = 6 THEN

UPDATE BAOGIA
SET BAOGIA.TTBG_ID = 2
WHERE BAOGIA.BAOGIA_ID = sms.BAOGIA_ID
  and baogia.phanvung_id = p_phanvung_id;

l_noidung_vuot_cap := 'Báo giá cần gửi thẩm định vượt cấp : ' || sms.MA_BAOGIA || ' ' || sms.TEN_BAOGIA || ' ' || sms.HAN_PHEDUYET || ' ' || p_url;

FOR recc IN (SELECT NV.so_dt
                            FROM ADMIN.NGUOIDUNG ND
                            INNER JOIN ADMIN.DS_QUYEN_ND QND ON ND.NGUOIDUNG_ID = QND.NGUOIDUNG_ID
                            INNER JOIN ADMIN.DS_QUYEN_MENU DSQMENU  ON DSQMENU.QUYEN_ID = QND.QUYEN_ID
                            INNER JOIN ADMIN.MENU MN ON MN.MENU_ID = DSQMENU.MENU_ID
                            INNER JOIN ADMIN.NHANVIEN NV ON NV.NHANVIEN_ID = ND.NHANVIEN_ID
                            WHERE MN.MENU_ID = p_menu_id  AND MN.ACTIVED = 1
                            AND ND.PHANVUNG_ID = p_phanvung_id
                            AND QND.PHANVUNG_ID = p_phanvung_id
                            AND NV.PHANVUNG_ID = p_phanvung_id)
                        LOOP
                            send_sms(p_phanvung_id, recc.so_dt, l_noidung_vuot_cap, l_ghichu, p_may_cn, p_nguoi_cn, p_ip_cn);
END LOOP;
                    -- insert lịch sử báo giá GP
                        PKG_OS_TCKH.SP_INSERT_UPDATE_BAO_GIA_GP(
                            sms.BAOGIA_ID,
                            p_phanvung_id,
                            p_ngay_cn,
                            null,
                            0,
                            0,
                            p_donvi_id,
                            p_nhanvien_id,
                            1,
                            null,
                            0,
                            0,
                            0,
                            p_may_cn,
                            p_nguoi_cn,
                            p_ip_cn,
                            p_ngay_cn,
                            l_huonggiao_id
                        );
                -- update gui tham dinh vuot cap
ELSE IF sms.LOAIBG_ID = 2 or sms.LOAIBG_ID = 5  THEN

UPDATE BAOGIA
SET BAOGIA.TTBG_ID = 2
WHERE BAOGIA.BAOGIA_ID = sms.BAOGIA_ID
  and baogia.phanvung_id = p_phanvung_id;

l_noidung_vuot_cap := 'Báo giá cần gửi thẩm định vượt cấp : ' || sms.MA_BAOGIA || ' ' || sms.TEN_BAOGIA || ' ' || sms.HAN_PHEDUYET || ' ' || p_url;

FOR rec IN (SELECT NV.so_dt FROM ADMIN.NGUOIDUNG ND
                            INNER  JOIN ADMIN.DS_QUYEN_ND QND ON ND.NGUOIDUNG_ID = QND.NGUOIDUNG_ID
                            INNER JOIN ADMIN.DS_QUYEN_MENU DSQMENU  ON DSQMENU.QUYEN_ID = QND.QUYEN_ID
                            INNER JOIN ADMIN.MENU MN ON MN.MENU_ID = DSQMENU.MENU_ID
                            INNER JOIN ADMIN.NHANVIEN NV ON NV.NHANVIEN_ID = ND.NHANVIEN_ID
                            WHERE MN.MENU_ID = p_menu_id AND MN.ACTIVED = 1
                            AND ND.PHANVUNG_ID = 97
                            AND QND.PHANVUNG_ID = 97
                            AND NV.PHANVUNG_ID = 97)
                        LOOP
                            send_sms(p_phanvung_id, rec.so_dt, l_noidung_vuot_cap, l_ghichu, p_may_cn, p_nguoi_cn, p_ip_cn);
END LOOP;
                    -- insert lịch sử báo giá GP
                        PKG_OS_TCKH.SP_INSERT_UPDATE_BAO_GIA_GP(
                            sms.BAOGIA_ID,
                            p_phanvung_id,
                            p_ngay_cn,
                            null,
                            0,
                            0,
                            p_donvi_id,
                            p_nhanvien_id,
                            1,
                            null,
                            0,
                            0,
                            0,
                            p_may_cn,
                            p_nguoi_cn,
                            p_ip_cn,
                            p_ngay_cn,
                            l_huonggiao_id
                        );
END IF;
END IF;
END IF;
END IF;
END LOOP;
                l_result := 'TRUE';
ELSE
         FOR abc in (select MA_BAOGIA from BAOGIA WHERE PHANVUNG_ID = p_phanvung_id and BAOGIA_ID member of p_bao_gia_id_lst)
            LOOP l_ma_baogia := l_ma_baogia || ', ' || abc.MA_BAOGIA;
END LOOP;
            l_ma_baogia := RTRIM(SUBSTR(l_ma_baogia,2,LENGTH(l_ma_baogia) ));
            l_result := 'Các mã báo giá sau : ' || l_ma_baogia ||' không hợp lệ! vui lòng kiểm tra lại';
END IF;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
--                    l_result := 'FALSE';
l_result := 'Co Loi xay ra ' ||sqlerrm;
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;
--api60
FUNCTION FN_GET_DS_NHANVIEN_TRONG_DONVI_SEL (
        p_donvi_id IN NUMBER,
        p_phan_vung_id IN NUMBER)
    RETURN SYS_REFCURSOR IS
        l_result      SYS_REFCURSOR;
BEGIN
    --Lay thong tin danh sach nhan vien
BEGIN
OPEN l_result FOR
SELECT  nv.NHANVIEN_ID nhanVienId, nv.TEN_NV tenNhanVien,nv.SO_DT soDTNhanVien, nv.EMAIL emailNhanVien
FROM admin.DONVI dv
         INNER JOIN admin.NHANVIEN nv
                    ON dv.DONVI_ID = nv.DONVI_ID
WHERE dv.DONVI_ID = p_donvi_id
  and nv.PHANVUNG_ID = p_phan_vung_id
  and dv.PHANVUNG_ID = p_phan_vung_id;
RETURN l_result;

EXCEPTION
              WHEN OTHERS THEN
BEGIN

                    --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                        || sqlerrm
                                        || ')'' name from dual';

RETURN l_result;
END;
END;
END;

--api56
FUNCTION FN_GET_DS_FILE_ATTACH_BG_SEL(
    p_bao_gia_id IN NUMBER,
    p_phanvung_id IN NUMBER)
    RETURN SYS_REFCURSOR IS
     l_result      SYS_REFCURSOR;
BEGIN
OPEN l_result FOR
select fileHs.file_id fileId, fileHs.ten_file tenFile, fileHs.url url,
       fileHs.kieufile_id kieuFileId, fileHs.loaifile_id loaiFileId, fileHs.trangthaihs_id tranThaiHSId
from admin.HS_BAOGIA hsBaoGia
         join admin.file_hs fileHs on hsbaogia.filehs_id = filehs.file_id
where hsBaoGia.BAOGIA_ID = p_bao_gia_id AND fileHs.PHANVUNG_ID = p_phanvung_id;

RETURN l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN

                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';

RETURN l_result;
END;
END;
--
FUNCTION FN_SEND_SMS_SCHEDULED_CHK(
    p_url           IN VARCHAR2)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_so_dt VARCHAR2(20);
    l_noidung VARCHAR2(2000);
    l_ghichu VARCHAR2(2000);
BEGIN
BEGIN
      -- call sms
        l_ghichu := 'Nhắn tin từ nghiệp vụ Gửi phê duyệt báo giá khách hàng';
FOR sms in (select BAOGIA_ID, MA_BAOGIA, HAN_PHEDUYET, TEN_BAOGIA, NGUOI_CN, IP_CN, MAY_CN, PHANVUNG_ID
                        from BAOGIA WHERE TTBG_ID = 5 AND TO_DATE(HAN_PHEDUYET, 'DD-MON-YY') = TO_DATE(sysdate, 'DD-MON-YY') )
            LOOP
SELECT nhanvien.so_dt INTO l_so_dt
FROM admin.nhanvien
         JOIN BAOGIA ON (nhanvien.nhanvien_id = BAOGIA.nhanvien_id AND nhanvien.DONVI_ID = BAOGIA.DONVI_ID)
         JOIN admin.NHANVIEN_LNV ON nhanvien.nhanvien_id = NHANVIEN_LNV.nhanvien_id
WHERE BAOGIA.BAOGIA_ID = sms.BAOGIA_ID and NHANVIEN_LNV.loainv_id = 104 and rownum = 1;

l_noidung := 'Báo giá cần phê duyệt : ' || sms.MA_BAOGIA || ' ' || sms.TEN_BAOGIA || ' ' || sms.HAN_PHEDUYET || ' ' || p_url;

            send_sms(sms.PHANVUNG_ID, l_so_dt, l_noidung, l_ghichu, sms.MAY_CN, sms.NGUOI_CN, sms.IP_CN);
END LOOP;
            l_result := 'TRUE';

EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
--                    l_result := 'FALSE';
l_result := 'Co Loi xay ra ' ||sqlerrm;
RETURN l_result;
END;
END;
RETURN l_result;
END;
--api 66
PROCEDURE SP_GET_PROPOSE_HIS_BAOGIA_LIST (
    p_ma_bao_gia IN VARCHAR2,
    p_loai_bao_gia IN NUMBER,
    p_dich_vu IN NUMBER,
    p_loai_hinh_tb IN NUMBER,
    p_don_vi_de_xuat IN NUMBER,
    p_nhan_vien_de_xuat IN NUMBER,
    p_phan_vung_id IN NUMBER,
    p_pn_page_id IN NUMBER,
    p_pn_rec_per_page IN NUMBER,
    v_cusor     OUT SYS_REFCURSOR,
    v_total     OUT number)
IS
    l_result      SYS_REFCURSOR;
    l_sql         VARCHAR2(20000);
BEGIN
    --Lay thong tin danh sach nhan vien
BEGIN
        l_sql := ' SELECT
                   bg.BAOGIA_ID idBaoGia,
                   bg.MA_BAOGIA maBaoGia,
                   bg.TEN_BAOGIA tenBaoGia,
                   lbg.LOAI_BG loaiBaoGia,
                   dv.TEN_DV tenDonVi,
                   TO_CHAR(bg.NGAY_CN, ''DD/MM/YYYY'') hieuLucTu,
                   TO_CHAR(bg.HIEULUC_TU, ''DD/MM/YYYY'') ngayBaoGia
                   FROM css.BAOGIA bg
                   JOIN css.LOAI_BG lbg ON bg.LOAIBG_ID = lbg.LOAIBG_ID
                   JOIN admin.DONVI dv ON dv.DONVI_ID = bg.DONVI_ID
                   JOIN admin.NHANVIEN nv ON nv.NHANVIEN_ID = bg.NHANVIEN_ID
                   JOIN css.BAOGIA_GC bggc ON bggc.BAOGIA_ID = bg.BAOGIA_ID
                   WHERE 1 = 1 ';

        -- Check phan vung
        IF p_phan_vung_id IS NOT NULL THEN
            l_sql := l_sql || ' AND bg.PHANVUNG_ID = ' || p_phan_vung_id;
            l_sql := l_sql || ' AND dv.PHANVUNG_ID = ' || p_phan_vung_id;
            l_sql := l_sql || ' AND nv.PHANVUNG_ID = ' || p_phan_vung_id;
END IF;

        -- Search theo ma bao gia
        IF p_ma_bao_gia IS NOT NULL THEN
            l_sql := l_sql || ' AND lower(bg.MA_BAOGIA) LIKE ''%' || lower(p_ma_bao_gia) || '%''' ;
END IF;

        -- Search theo don vi
        IF p_don_vi_de_xuat IS NOT NULL THEN
            l_sql := l_sql || ' AND bg.DONVI_ID = ' || p_don_vi_de_xuat;
END IF;

        -- Search theo nhan vien
        IF p_nhan_vien_de_xuat IS NOT NULL THEN
            l_sql := l_sql || ' AND bg.NHANVIEN_ID = ' || p_nhan_vien_de_xuat;
END IF;

        -- Search theo dich vu
        IF p_dich_vu IS NOT NULL THEN
            l_sql := l_sql || ' AND bggc.DICHVUVT_ID = ' || p_dich_vu;
END IF;

        -- Search theo loai hinh
        IF p_loai_hinh_tb IS NOT NULL THEN
            l_sql := l_sql || ' AND bggc.LOAIHINHTB_ID = ' || p_loai_hinh_tb;
END IF;

        l_sql := l_sql || ' ORDER BY bg.ngay_cn desc ';

        --lay count data truoc khi qua phan trang
        dbms_output.put_line(v_total);
        v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);

        --lay data cusor sau phan trang
        dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN
            --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                 || sqlerrm
                                 || ')'' name from dual';
v_total := 0;
            v_cusor := l_result;

END;
END;
END;
--api67
PROCEDURE SP_GET_APPROVAL_HIS_BAOGIA_LIST (
    p_id_bao_gia_list IN VARCHAR2,
    p_phan_vung_id IN NUMBER,
    p_pn_page_id IN NUMBER,
    p_pn_rec_per_page IN NUMBER,
    v_cusor     OUT SYS_REFCURSOR,
    v_total     OUT number)
IS
    l_result      SYS_REFCURSOR;
    l_sql         VARCHAR2(20000);
    l_id_bao_gia_list  VARCHAR2(20000);
BEGIN
    --Lay thong tin danh sach nhan vien
BEGIN
        l_sql := ' SELECT
                   dv1.TEN_DV donViBaoGia,
                   dvg.TEN_DV donViGiaoThamDinh,
                   TO_CHAR(bggp.NGAYGIAO, ''DD/MM/YYYY'') ngayGiao,
                   nvg.TEN_NV nguoiGiao,
                   dvn.TEN_DV donViNhan,
                   nvn.TEN_NV nguoiNhan,
                   bggp.ND_THUCHIEN noiDungYKien,
                   bggp.NGUOI_CN nguoiCapNhat,
                   TO_CHAR(bggp.NGAY_CN, ''DD/MM/YYYY'') ngayCapNhat
                   FROM css.BAOGIA bg
                   JOIN css.BAOGIA_GP bggp ON bggp.BAOGIA_ID = bg.BAOGIA_ID
                   JOIN admin.DONVI dv1 ON dv1.DONVI_ID = bg.DONVI_ID
                   JOIN admin.DONVI dvn ON dvn.DONVI_ID = bggp.DONVI_NHAN_ID
                   JOIN admin.DONVI dvg ON dvg.DONVI_ID = bggp.DONVI_GIAO_ID
                   JOIN admin.NHANVIEN nvg ON nvg.NHANVIEN_ID = bggp.NHANVIEN_GIAO_ID
                   JOIN admin.NHANVIEN nvn ON nvn.NHANVIEN_ID = bggp.NHANVIEN_NHAN_ID
                   WHERE 1 = 1 ';

        -- Check phan vung
        IF p_phan_vung_id IS NOT NULL THEN
            l_sql := l_sql || ' AND bg.PHANVUNG_ID = ' || p_phan_vung_id;
            l_sql := l_sql || ' AND bggp.PHANVUNG_ID = ' || p_phan_vung_id;
            l_sql := l_sql || ' AND dv1.PHANVUNG_ID = ' || p_phan_vung_id;
            l_sql := l_sql || ' AND dvn.PHANVUNG_ID = ' || p_phan_vung_id;
            l_sql := l_sql || ' AND dvg.PHANVUNG_ID = ' || p_phan_vung_id;
            l_sql := l_sql || ' AND nvg.PHANVUNG_ID = ' || p_phan_vung_id;
            l_sql := l_sql || ' AND nvn.PHANVUNG_ID = ' || p_phan_vung_id;
END IF;

        IF p_id_bao_gia_list IS NOT NULL THEN
                FOR rec IN (
                    SELECT value
                    FROM
                        (SELECT regexp_substr (p_id_bao_gia_list, '[^,]+', 1, LEVEL) value
                    FROM dual CONNECT BY LEVEL <= LENGTH (p_id_bao_gia_list) - LENGTH
                        (REPLACE (p_id_bao_gia_list,',')) + 1))
                LOOP
                    l_id_bao_gia_list := l_id_bao_gia_list || '' || rec.value || ',';
END LOOP;

                l_id_bao_gia_list := RTRIM(SUBSTR(l_id_bao_gia_list, 0, LENGTH(l_id_bao_gia_list) -1));
                dbms_output.put_line(l_id_bao_gia_list);
                l_sql := l_sql || ' AND bggp.BAOGIA_ID IN (' || l_id_bao_gia_list || ')';

END IF;

        l_sql := l_sql || ' ORDER BY bg.ngay_cn desc ';

        --lay count data truoc khi qua phan trang
        dbms_output.put_line(v_total);
        v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);

        --lay data cusor sau phan trang
        dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN
            --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                 || sqlerrm
                                 || ')'' name from dual';
v_total := 0;
            v_cusor := l_result;

END;
END;
END;
-- api thẩm định báo giá
FUNCTION FN_THAM_DINH_BAO_GIA_CHK(
	p_bao_gia_id IN NUMBER,
    p_url           IN VARCHAR2,
    p_phanvung_id   IN NUMBER,
    p_nhanvien_id   IN NUMBER,
    p_donvi_id      IN NUMBER,
    p_may_cn        IN VARCHAR2,
    p_nguoi_cn      IN VARCHAR2,
    p_ip_cn         IN VARCHAR2,
    p_ngay_cn	    IN DATE,
    p_y_kien        IN VARCHAR2)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_so_dt VARCHAR2(20);
    l_count_record NUMBER;
    l_ma_baogia VARCHAR2(2000);
BEGIN
BEGIN
SAVEPOINT ABC;
--get danh sach id bao gia
SELECT count(BAOGIA_ID) INTO l_count_record
FROM BAOGIA
WHERE BAOGIA_ID = p_bao_gia_id
  AND (BAOGIA.TTBG_ID = 2 OR BAOGIA.TTBG_ID = 3 )
  AND baogia.phanvung_id = p_phanvung_id;
IF l_count_record = 1 THEN
UPDATE BAOGIA
SET BAOGIA.TTBG_ID = 4
WHERE BAOGIA.BAOGIA_ID = p_bao_gia_id
  AND baogia.phanvung_id = p_phanvung_id;
-- update lịch sử báo giá GP
PKG_OS_TCKH.SP_INSERT_UPDATE_BAO_GIA_GP(
                        p_bao_gia_id,
                        p_phanvung_id,
                        p_ngay_cn,
                        null,
                        0,
                        p_nhanvien_id,
                        0,
                        0,
                        2,
                        p_ngay_cn,
                        p_nhanvien_id,
                        p_donvi_id,
                        p_y_kien,
                        p_may_cn,
                        p_nguoi_cn,
                        p_ip_cn,
                        p_ngay_cn,
                        0
                        );
            l_result := 'TRUE';

ELSE
select MA_BAOGIA INTO l_ma_baogia from BAOGIA WHERE BAOGIA_ID = p_bao_gia_id and PHANVUNG_ID = p_phanvung_id;

l_result := 'Mã báo giá sau : ' || l_ma_baogia ||' không hợp lệ! vui lòng kiểm tra lại';
END IF;
EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
--                    l_result := 'FALSE';
l_result := 'Co Loi xay ra ' ||sqlerrm;
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;
-- api từ chối thẩm định báo giá
FUNCTION FN_TU_CHOI_THAM_DINH_BAO_GIA_CHK(
	p_bao_gia_id IN NUMBER,
    p_phanvung_id   IN NUMBER,
    p_nhanvien_id   IN NUMBER,
    p_donvi_id      IN NUMBER,
    p_may_cn        IN VARCHAR2,
    p_nguoi_cn      IN VARCHAR2,
    p_ip_cn         IN VARCHAR2,
    p_ngay_cn	    IN DATE,
    p_y_kien        IN VARCHAR2)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_so_dt VARCHAR2(20);
    l_count_record NUMBER;
    l_loai_bg NUMBER;
    l_ma_baogia VARCHAR2(2000);
BEGIN
BEGIN
SAVEPOINT ABC;
--get danh sach id bao gia
SELECT count(BAOGIA_ID) INTO l_count_record
FROM BAOGIA
WHERE BAOGIA_ID = p_bao_gia_id
  AND ((BAOGIA.TTBG_ID = 3 AND LOAIBG_ID = 1) OR
       ( BAOGIA.TTBG_ID = 2 AND LOAIBG_ID IN (2,3,4,5,6)))
  AND baogia.phanvung_id = p_phanvung_id;
IF l_count_record = 1 THEN
SELECT LOAIBG_ID INTO l_loai_bg FROM BAOGIA WHERE BAOGIA_ID = p_bao_gia_id;
IF l_loai_bg = 1 THEN
UPDATE BAOGIA
SET BAOGIA.TTBG_ID = 8
WHERE BAOGIA.BAOGIA_ID = p_bao_gia_id
  AND baogia.phanvung_id = p_phanvung_id;
ELSE
UPDATE BAOGIA
SET BAOGIA.TTBG_ID = 7
WHERE BAOGIA.BAOGIA_ID = p_bao_gia_id
  AND baogia.phanvung_id = p_phanvung_id;
END IF;
            -- update lịch sử báo giá GP
                PKG_OS_TCKH.SP_INSERT_UPDATE_BAO_GIA_GP(
                        p_bao_gia_id,
                        p_phanvung_id,
                        null,
                        null,
                        0,
                        p_nhanvien_id,
                        0,
                        0,
                        3,
                        p_ngay_cn,
                        p_nhanvien_id,
                        p_donvi_id,
                        p_y_kien,
                        p_may_cn,
                        p_nguoi_cn,
                        p_ip_cn,
                        p_ngay_cn,
                        0
                        );
            l_result := 'TRUE';
ELSE
select MA_BAOGIA INTO l_ma_baogia from BAOGIA WHERE BAOGIA_ID = p_bao_gia_id;

l_result := 'Mã báo giá sau : ' || l_ma_baogia ||' không hợp lệ! vui lòng kiểm tra lại';
END IF;
EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
--                    l_result := 'FALSE';
l_result := 'Co Loi xay ra ' ||sqlerrm;
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;

FUNCTION FN_GET_DS_CHI_TIET_KHOAN_MUC_LIST(
  p_bao_gia_id IN NUMBER,
  p_phanvung_id   IN NUMBER)
    RETURN SYS_REFCURSOR IS
        l_result      SYS_REFCURSOR;
BEGIN
     --Lay thong tin danh sach dich vu
BEGIN
OPEN l_result FOR
SELECT
    ct_bg.mota moTa,
    ct_bg.dv_tinh donViTinh,
    0 tienThietBi,
    0 cuocLapDat,
    0 ck,
    0 ckToiDa,
    ct_bg.tien thanhTien,
    0 tongTien,
    ct_bg.id idCtTienBG,
    COUNT(1) soLuong,
    ct_bg.khoanmuctt_id khoanMucId,
    (SELECT TEN_KMTT FROM KHOANMUC_TT WHERE KHOANMUCTT_ID = ct_bg.KHOANMUCTT_ID) tenKhoanMuc,
    0 hangMucId,
    null hangMuc,
    0 phiDuyTri,
    ct_bg.vat vat,
    'PHI_KHAC' type,
    0 dvgtVatLapDat,
    0 dvgtGiaBlock,
    0 dvgtVatBlock,
    0 gcLoaiGoi,
    0 gcDichVuVtId,
    0 gcLoaiHinhId,
    0 gcTocDoId,
    0 gcTien,
    0 gcVat,
    0 gcMucCuocTb,
    0 gcTienTraTruoc,
    0 gcVatTraTruoc,
    0 tbTien,
    0 tbVat,
    null tbSerial,
    0 tbTienTraTruoc,
    0 tbVatTraTruoc,
    0 tbTienKm,
    0 tbVatKm,
    0 tbSlCha
FROM ct_tienbg ct_bg
WHERE ct_bg.BAOGIA_ID = p_bao_gia_id
  AND ct_bg.phanvung_id = p_phanvung_id
  AND ID = 1 AND LOAI_ID = 1
GROUP BY ct_bg.mota, ct_bg.dv_tinh,ct_bg.tien,ct_bg.id, ct_bg.khoanmuctt_id, ct_bg.vat
UNION ALL
SELECT
    ct_bg.mota moTa,
    ct_bg.dv_tinh donViTinh,
    bg_tb.tien tienThietBi,
    0 cuocLapDat,
    0 ck,
    0 ckToiDa,
    ct_bg.tien thanhTien,
    bg_tb.tong_tien tongTien,
    ct_bg.id idCtTienBG,
    bg_tb.soluong soLuong,
    0 khoanMucId,
    null tenKhoanMuc,
    bg_tb.thietbi_id hangMucId,
    (SELECT LOAI_TBI FROM LOAI_TBI WHERE LOAITBI_ID = bg_tb.THIETBI_ID) hangMuc,
    0 phiDuyTri,
    ct_bg.vat vat,
    'MUA_THIET_BI' type,
    0 dvgtVatLapDat,
    0 dvgtGiaBlock,
    0 dvgtVatBlock,
    0 gcLoaiGoi,
    0 gcDichVuVtId,
    0 gcLoaiHinhId,
    0 gcTocDoId,
    0 gcTien,
    0 gcVat,
    0 gcMucCuocTb,
    0 gcTienTraTruoc,
    0 gcVatTraTruoc,
    bg_tb.TIEN tbTien,
    bg_tb.VAT tbVat,
    bg_tb.SERIAL tbSerial,
    bg_tb.TIEN_TRATRUOC tbTienTraTruoc,
    bg_tb.VAT_TRATRUOC tbVatTraTruoc,
    bg_tb.TIEN_KM tbTienKm,
    bg_tb.VAT_KM tbVatKm,
    bg_tb.SL_CHA tbSlCha
FROM ct_tienbg ct_bg
         Left join BAOGIA_TBI bg_tb on ct_bg.id = bg_tb.BAOGIA_TBI_ID AND ct_bg.phanvung_id = bg_tb.phanvung_id
WHERE ct_bg.BAOGIA_ID = p_bao_gia_id
  AND ct_bg.phanvung_id = p_phanvung_id
  AND ct_bg.LOAI_ID = 3
  AND (ct_bg.KHOANMUCTT_ID = 5 OR ct_bg.KHOANMUCTT_ID = 25)
GROUP BY ct_bg.mota, ct_bg.dv_tinh, bg_tb.tien, ct_bg.tien,
         bg_tb.tong_tien, ct_bg.id, bg_tb.soluong, bg_tb.thietbi_id, ct_bg.vat,
         bg_tb.VAT, bg_tb.SERIAL, bg_tb.TIEN_TRATRUOC, bg_tb.VAT_TRATRUOC,
         bg_tb.TIEN_KM, bg_tb.VAT_KM, bg_tb.SL_CHA
UNION ALL
SELECT
    ct_bg.mota moTa,
    ct_bg.dv_tinh donViTinh,
    0 tienThietBi,
    bg_dvgt.cuoc_ld cuocLapDat,
    0 ck,
    0 ckToiDa,
    ct_bg.tien thanhTien,
    0 tongTien,
    ct_bg.id idCtTienBG,
    bg_dvgt.soluong soLuong,
    0 khoanMucId,
    null tenKhoanMuc,
    bg_dvgt.dichvugt_id hangMucId,
    (SELECT TEN_DVGT FROM DICHVU_GT WHERE DICHVUGT_ID = bg_dvgt.DICHVUGT_ID) hanhMuc,
    bg_dvgt.cuoc_sd phiDuyTri,
    ct_bg.vat vat,
    'DICH_VU_CONG_THEM' type,
    bg_dvgt.VAT_LD dvgtVatLapDat,
    bg_dvgt.GIA_BLOCK_TIEP dvgtGiaBlock,
    bg_dvgt.VAT_BLOCK_TIEP dvgtVatBlock,
    0 gcLoaiGoi,
    0 gcDichVuVtId,
    0 gcLoaiHinhId,
    0 gcTocDoId,
    0 gcTien,
    0 gcVat,
    0 gcMucCuocTb,
    0 gcTienTraTruoc,
    0 gcVatTraTruoc,
    0 tbTien,
    0 tbVat,
    null tbSerial,
    0 tbTienTraTruoc,
    0 tbVatTraTruoc,
    0 tbTienKm,
    0 tbVatKm,
    0 tbSlCha
FROM ct_tienbg ct_bg
         Left join BAOGIA_DVGT bg_dvgt on ct_bg.id = bg_dvgt.BG_DVGT_ID AND ct_bg.phanvung_id = bg_dvgt.phanvung_id
WHERE ct_bg.BAOGIA_ID = p_bao_gia_id
  AND ct_bg.phanvung_id = p_phanvung_id
  AND ct_bg.LOAI_ID = 2
  AND ct_bg.KHOANMUCTT_ID = 4
GROUP BY ct_bg.mota, ct_bg.dv_tinh, bg_dvgt.cuoc_ld, ct_bg.tien,
         ct_bg.id, bg_dvgt.soluong, bg_dvgt.dichvugt_id, bg_dvgt.cuoc_sd, ct_bg.vat,bg_dvgt.VAT_LD,
         bg_dvgt.GIA_BLOCK_TIEP, bg_dvgt.VAT_BLOCK_TIEP
UNION ALL
SELECT
    ct_bg.mota moTa,
    ct_bg.dv_tinh donViTinh,
    0 tienThietBi,
    0 cuocLapDat,
    bctkm.ck ck,
    bctkm.ck_toida ckToiDa,
    ct_bg.tien thanhTien,
    0 tongTien,
    ct_bg.id idCtTienBG,
    (TO_NUMBER(bg_gc.soluong)) soLuong,
    0 khoanMucId,
    null tenKhoanMuc,
    case
        when (SELECT CTKM.CHITIETKM_ID  FROM BAOGIA_GC BGGC,CT_KHUYENMAI CTKM,BAOGIA_CTKM BGKM
              WHERE
                  BGGC.BAOGIA_GC_ID = BGKM.BAOGIA_GC_ID
                AND
                  CTKM.CHITIETKM_ID = BGKM.CHITIETKM_ID
                AND BGGC.BAOGIA_ID = ct_bg.id) IS not null then
            (SELECT CTKM.CHITIETKM_ID  FROM BAOGIA_GC BGGC,CT_KHUYENMAI CTKM,BAOGIA_CTKM BGKM
             WHERE
                 BGGC.BAOGIA_GC_ID = BGKM.BAOGIA_GC_ID
               AND
                 CTKM.CHITIETKM_ID = BGKM.CHITIETKM_ID
               AND BGGC.BAOGIA_ID = ct_bg.id)
        when bg_gc.loai_goi = 1
            then
            (bg_gc.LOAIHINHTB_ID )
        when bg_gc.loai_goi = 2
            then
            (bg_gc.goi_id )
        end AS hangMucId,
    case
        when (SELECT TEN_CTKM FROM BAOGIA_GC BGGC,CT_KHUYENMAI CTKM,BAOGIA_CTKM BGKM
              WHERE
                  BGGC.BAOGIA_GC_ID = BGKM.BAOGIA_GC_ID
                AND
                  CTKM.CHITIETKM_ID = BGKM.CHITIETKM_ID
                AND BGGC.BAOGIA_ID = ct_bg.id) IS not null then
            (SELECT TEN_CTKM FROM BAOGIA_GC BGGC,CT_KHUYENMAI CTKM,BAOGIA_CTKM BGKM
             WHERE
                 BGGC.BAOGIA_GC_ID = BGKM.BAOGIA_GC_ID
               AND
                 CTKM.CHITIETKM_ID = BGKM.CHITIETKM_ID
               AND BGGC.BAOGIA_ID = ct_bg.id)
        when bg_gc.loai_goi = 1
            then
            (select TEN_DV from LOAIHINH_TB where LOAITB_ID = bg_gc.LOAIHINHTB_ID )
        when bg_gc.loai_goi = 2
            then
            (select TEN_GOI from GOI_DADV where goi_id = bg_gc.goi_id )
        end AS hangMuc,
    case
        when (SELECT ctkm.CHITIETKM_ID FROM BAOGIA_GC BGGC,CT_KHUYENMAI CTKM,BAOGIA_CTKM BGKM
              WHERE
                  BGGC.BAOGIA_GC_ID = BGKM.BAOGIA_GC_ID
                AND
                  CTKM.CHITIETKM_ID = BGKM.CHITIETKM_ID
                AND BGGC.BAOGIA_ID = ct_bg.id) IS not null then
            (SELECT CTKM.DATCOC_CSD FROM BAOGIA_GC BGGC,CT_KHUYENMAI CTKM,BAOGIA_CTKM BGKM
             WHERE
                 BGGC.BAOGIA_GC_ID = BGKM.BAOGIA_GC_ID
               AND
                 CTKM.CHITIETKM_ID = BGKM.CHITIETKM_ID
               AND BGGC.BAOGIA_ID = ct_bg.id)
        when bg_gc.loai_goi = 1
            then
            (select CUOC_TB  from muccuoc_tb where MUCUOCTB_ID = bg_gc.muccuoctb_id )
        when bg_gc.loai_goi = 2
            then
            (select tien from GOI_DADV where goi_id = bg_gc.goi_id )
        end AS phiDuyTri,
    ct_bg.vat,
    'CUOC_SU_DUNG' type,
    0 dvgtVatLapDat,
    0 dvgtGiaBlock,
    0 dvgtVatBlock,
    bg_gc.LOAI_GOI gcLoaiGoi,
    bg_gc.DICHVUVT_ID gcDichVuVtId,
    bg_gc.LOAIHINHTB_ID gcLoaiHinhId,
    bg_gc.TOCDO_ID gcTocDoId,
    bg_gc.TIEN gcTien,
    bg_gc.VAT gcVat,
    bg_gc.TIEN gcMucCuocTb,
    bctkm.DATCOC_CSD gcTienTraTruoc,
    bctkm.TYLE_VAT gcVatTraTruoc,
    0 tbTien,
    0 tbVat,
    null tbSerial,
    0 tbTienTraTruoc,
    0 tbVatTraTruoc,
    0 tbTienKm,
    0 tbVatKm,
    0 tbSlCha
FROM ct_tienbg ct_bg
         Left join BAOGIA_GC bg_gc on ct_bg.id = bg_gc.BAOGIA_GC_ID
         left JOIN baogia_ctkm bctkm on bctkm.baogia_id = ct_bg.baogia_id
WHERE ct_bg.BAOGIA_ID = p_bao_gia_id
  AND ct_bg.phanvung_id = p_phanvung_id
  AND ct_bg.LOAI_ID = 1 AND ct_bg.KHOANMUCTT_ID = 21
GROUP BY ct_bg.mota, ct_bg.dv_tinh, bctkm.ck, bctkm.ck_toida, ct_bg.tien,
         ct_bg.id, bg_gc.soluong, bg_gc.loai_goi, bg_gc.LOAIHINHTB_ID, bg_gc.goi_id, ct_bg.vat, bg_gc.muccuoctb_id,
         bg_gc.DICHVUVT_ID, bg_gc.TOCDO_ID, bg_gc.TIEN, bg_gc.VAT,
         bctkm.DATCOC_CSD, bctkm.TYLE_VAT;

RETURN l_result;

EXCEPTION
        WHEN OTHERS THEN
BEGIN

                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';

RETURN l_result;
END;
END;
END;
-- api 68
PROCEDURE SP_GET_DS_BAO_GIA_PHE_DUYET_LIST(
  p_trang_thai_bao_gia IN LIST_NUMBER,
  p_nhan_vien_id IN NUMBER,
  p_type_get IN NUMBER,
  p_pn_page_id IN NUMBER,
  p_pn_rec_per_page IN NUMBER,
  p_phanvung_id   IN NUMBER,
  v_cusor     OUT SYS_REFCURSOR,
  v_total     OUT number
  )
is
     l_result   SYS_REFCURSOR;
     l_sql      VARCHAR2(20000);
     l_trang_thai_bao_gia      VARCHAR2(20000);
     l_countTotal number:=0;
     l_count_record NUMBER(1);
BEGIN

SELECT COUNT(1) INTO l_count_record FROM trangthai_bg
WHERE trangthai_bg.TTBG_ID member of p_trang_thai_bao_gia;

IF l_count_record = p_trang_thai_bao_gia.COUNT THEN

        FOR rec IN (SELECT TTBG_ID FROM trangthai_bg
            WHERE trangthai_bg.TTBG_ID member of p_trang_thai_bao_gia)
        LOOP
            l_trang_thai_bao_gia := l_trang_thai_bao_gia || ',' || rec.TTBG_ID;
END LOOP;

        l_trang_thai_bao_gia  := SUBSTR(l_trang_thai_bao_gia, 2, LENGTH(l_trang_thai_bao_gia) -1);

         --Lay thong tin danh sach dich vu
        l_sql := 'SELECT bg.baogia_id idBaoGia ,
            bg.ma_baogia maBaoGia ,
            bg.ten_baogia tenBaoGia ,
            bg.han_pheduyet hanPheDuyet ,
            bg.han_lapdat hanLapDat ,
            bg.hieuluc_tu hieuLucTuNgay ,
            bg.hieuluc_den hieuLucDenNgay ,
            bg.loaibg_id loaiBaoGia ,
            bg.nhom_dv nhomDichVu ,
            bg.nguon nguon ,
            bg.nguon_id nguonId ,
            ph.TRANGTHAI ketQua,
            kh.khachhang_id idKhachHang ,
            kh.ma_kh maKhachHang ,
            kh.ten_kh tenKhachHang ,
            kh.diachi_kh diaChiKhachHang ,
            kh.mst mstKhachHang ,
            bg.nguoi_lh nguoiLienHe ,
            bg.so_dt soDienThoaiLienHe ,
            bg.email emailLienHe ,
            bg.ghichu ghiChu,
            loaibg.loai_bg tenLoaiBaoGia,
            bg.donvi_id IDDonVIBaoGia,
            donvi.ten_dv tenDonViBaoGia
            FROM baogia bg
            JOIN db_khachhang kh ON kh.khachhang_id = bg.khachhang_id
            JOIN loai_bg loaibg on loaibg.loaibg_id = bg.loaibg_id
            JOIN admin.donvi donvi on donvi.donvi_id = bg.donvi_id
            JOIN BAOGIA_GP bggp ON bggp.BAOGIA_ID = bg.BAOGIA_ID
            JOIN TRANGTHAI_PH ph ON ph.TTPHIEU_ID = bggp.TTPHIEU_ID ';

            l_sql := l_sql || ' where bg.ttbg_id IN( ' ||  l_trang_thai_bao_gia || ')' ;
            l_sql := l_sql || ' and bg.nhanvien_id = ' ||  p_nhan_vien_id;
            l_sql := l_sql || ' and bg.phanvung_id = ' ||  p_phanvung_id;
            l_sql := l_sql || ' and kh.phanvung_id = ' ||  p_phanvung_id;
            l_sql := l_sql || ' and bggp.phanvung_id = ' ||  p_phanvung_id;
            l_sql := l_sql || ' and donvi.phanvung_id = ' ||  p_phanvung_id;

            IF p_type_get = 1 THEN
                l_sql := l_sql || ' and bggp.TTPHIEU_ID = 1 ';
ELSE IF p_type_get = 2 THEN
                l_sql := l_sql || ' and bggp.TTPHIEU_ID = 2 ';
ELSE l_sql := l_sql || ' and bggp.TTPHIEU_ID IN ( 2, 3 ) ';
END IF;
END IF;
            l_sql := l_sql || ' ORDER BY bg.ngay_cn DESC ';


            --lay count data truoc khi qua phan trang
            dbms_output.put_line(v_total);
            v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);

            --lay data cusor sau phan trang
            dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;
ELSE
                v_total := 0;
                v_cusor := null;
END IF;
EXCEPTION
        WHEN OTHERS THEN
BEGIN
                --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                     || sqlerrm
                                     || ')'' name from dual';
v_total := 0;
                v_cusor := l_result;

END;
END;
-- insert or update baogia_gp
PROCEDURE SP_INSERT_UPDATE_BAO_GIA_GP(
	p_bao_gia_id            IN NUMBER,
    p_phanvung_id           IN NUMBER,
    p_ngay_giao	            IN DATE,
    p_nd_giao	            IN VARCHAR2,
    p_donvi_nhan_id         IN NUMBER,
    p_nhanvien_nhan_id      IN NUMBER,
    p_donvi_giao_id         IN NUMBER,
    p_nhanvien_giao_id      IN NUMBER,
    p_ttphieu_id            IN NUMBER,
    p_ngay_th	            IN DATE,
    p_nhanvien_th_id        IN NUMBER,
    p_donvi_th_id           IN NUMBER,
    p_nd_thuchien           IN VARCHAR2,
    p_may_cn                IN VARCHAR2,
    p_nguoi_cn              IN VARCHAR2,
    p_ip_cn                 IN VARCHAR2,
    p_ngay_cn	            IN DATE,
    p_huonggiao_id          IN NUMBER)
IS
	l_result VARCHAR2(4000);
    l_count_record NUMBER;
    l_loaibg_id NUMBER;
BEGIN
BEGIN
SAVEPOINT ABC;
SELECT LOAIBG_ID INTO l_loaibg_id FROM BAOGIA WHERE BAOGIA_ID = p_bao_gia_id;
IF l_loaibg_id = 1 THEN
            IF p_ttphieu_id = 1 THEN
DELETE FROM BAOGIA_GP WHERE BAOGIA_ID = p_bao_gia_id and phanvung_id = p_phanvung_id;
INSERT INTO BAOGIA_GP(
    PHIEU_ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    NGAYGIAO,
    DONVI_GIAO_ID,
    NHANVIEN_GIAO_ID,
    TTPHIEU_ID,
    NGUOI_CN,
    IP_CN,
    MAY_CN,
    NGAY_CN,
    HUONGGIAO_ID
)
VALUES(
          SEQ_BAOGIA_GP.nextval,
          p_phanvung_id,
          p_bao_gia_id,
          p_ngay_giao,
          p_donvi_giao_id,
          p_nhanvien_giao_id,
          p_ttphieu_id,
          p_nguoi_cn,
          p_ip_cn,
          p_may_cn,
          p_ngay_cn,
          p_huonggiao_id
      );
ELSE IF p_ttphieu_id = 2 THEN
UPDATE BAOGIA_GP
SET NGAYGIAO = p_ngay_giao,
    NHANVIEN_NHAN_ID = p_nhanvien_nhan_id,
    TTPHIEU_ID = p_ttphieu_id,
    NGAY_TH = p_ngay_th,
    NHANVIEN_TH_ID = p_nhanvien_th_id,
    DONV_TH_ID = p_donvi_th_id,
    ND_THUCHIEN = p_nd_thuchien,
    NGUOI_CN = p_nguoi_cn,
    IP_CN = p_ip_cn,
    MAY_CN = p_may_cn,
    NGAY_CN = p_ngay_cn
WHERE BAOGIA_ID = p_bao_gia_id and phanvung_id = p_phanvung_id;
ELSE
UPDATE BAOGIA_GP
SET NGAYGIAO = null,
    NHANVIEN_NHAN_ID = null,
    TTPHIEU_ID = p_ttphieu_id,
    NGAY_TH = p_ngay_th,
    NHANVIEN_TH_ID = p_nhanvien_th_id,
    DONV_TH_ID = p_donvi_th_id,
    ND_THUCHIEN = p_nd_thuchien,
    NGUOI_CN = p_nguoi_cn,
    IP_CN = p_ip_cn,
    MAY_CN = p_may_cn,
    NGAY_CN = p_ngay_cn
WHERE BAOGIA_ID = p_bao_gia_id and phanvung_id = p_phanvung_id;
END IF;
END IF;
ELSE
            IF p_ttphieu_id = 1 THEN
DELETE FROM BAOGIA_GP WHERE BAOGIA_ID = p_bao_gia_id and phanvung_id = p_phanvung_id;
INSERT INTO BAOGIA_GP(
    PHIEU_ID,
    PHANVUNG_ID,
    BAOGIA_ID,
    NGAYGIAO,
    DONVI_GIAO_ID,
    NHANVIEN_GIAO_ID,
    TTPHIEU_ID,
    NGUOI_CN,
    IP_CN,
    MAY_CN,
    NGAY_CN,
    HUONGGIAO_ID
)
VALUES(
          SEQ_BAOGIA_GP.nextval,
          p_phanvung_id,
          p_bao_gia_id,
          p_ngay_giao,
          p_donvi_giao_id,
          p_nhanvien_giao_id,
          p_ttphieu_id,
          p_nguoi_cn,
          p_ip_cn,
          p_may_cn,
          p_ngay_cn,
          p_huonggiao_id
      );
ELSE IF p_ttphieu_id = 2 THEN
UPDATE BAOGIA_GP
SET NGAYGIAO = null,
    NHANVIEN_NHAN_ID = p_nhanvien_nhan_id,
    TTPHIEU_ID = p_ttphieu_id,
    NGAY_TH = p_ngay_th,
    NHANVIEN_TH_ID = p_nhanvien_th_id,
    DONV_TH_ID = p_donvi_th_id,
    ND_THUCHIEN = p_nd_thuchien,
    NGUOI_CN = p_nguoi_cn,
    IP_CN = p_ip_cn,
    MAY_CN = p_may_cn,
    NGAY_CN = p_ngay_cn
WHERE BAOGIA_ID = p_bao_gia_id and phanvung_id = p_phanvung_id;
ELSE
UPDATE BAOGIA_GP
SET NGAYGIAO = null,
    NHANVIEN_NHAN_ID = null,
    TTPHIEU_ID = p_ttphieu_id,
    NGAY_TH = p_ngay_th,
    NHANVIEN_TH_ID = p_nhanvien_th_id,
    DONV_TH_ID = p_donvi_th_id,
    ND_THUCHIEN = p_nd_thuchien,
    NGUOI_CN = p_nguoi_cn,
    IP_CN = p_ip_cn,
    MAY_CN = p_may_cn,
    NGAY_CN = p_ngay_cn
WHERE BAOGIA_ID = p_bao_gia_id and phanvung_id = p_phanvung_id;
END IF;
END IF;
END IF;
EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
END;
END;
COMMIT;
END;
-- api phê duyệt báo giá
FUNCTION FN_PHE_DUYET_BAO_GIA_SEL_CHK(
	p_bao_gia_id IN NUMBER,
    p_url           IN VARCHAR2,
    p_phanvung_id   IN NUMBER,
    p_may_cn        IN VARCHAR2,
    p_nguoi_cn      IN VARCHAR2,
    p_ip_cn         IN VARCHAR2,
    p_ngay_cn	    IN DATE,
    p_y_kien        IN VARCHAR2,
    p_don_vi_thuc_thi  IN NUMBER,
    p_nhan_vien_id   IN NUMBER)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_so_dt VARCHAR2(20);
    l_count_record NUMBER;
    l_noidung VARCHAR2(200);
    l_ghichu VARCHAR2(200);
    l_ma_baogia VARCHAR2(2000);
    l_han_phe_duyet DATE;
    l_ten_bao_gia VARCHAR2(500);
BEGIN
BEGIN
SAVEPOINT ABC;
--get danh sach id bao gia
Select count(bg.BAOGIA_ID)  INTO l_count_record
FROM baogia bg
         JOIN BAOGIA_GP bggp ON bggp.BAOGIA_ID = bg.BAOGIA_ID
         JOIN TRANGTHAI_PH ph ON ph.TTPHIEU_ID = bggp.TTPHIEU_ID
where bg.ttbg_id IN(2,3,4,5,7,8)
  and bg.BAOGIA_ID = p_bao_gia_id
  and bggp.TTPHIEU_ID IN (1,2,3)
  and bg.nhanvien_id = p_nhan_vien_id
  and bg.phanvung_id = p_phanvung_id
  and bggp.phanvung_id = p_phanvung_id;

dbms_output.put_line(1);
        -- Truong hop co ton tai iid bao gia
        IF l_count_record <> 0 THEN

            -- Update trang thai bao gia
UPDATE BAOGIA
SET BAOGIA.TTBG_ID = 6,
    BAOGIA.NGAY_CN = p_ngay_cn,
    BAOGIA.NGUOI_CN = p_nguoi_cn
WHERE BAOGIA.BAOGIA_ID = p_bao_gia_id AND PHANVUNG_ID = p_phanvung_id;
dbms_output.put_line(2);
            -- Gui sms
            l_ghichu := 'Nhắn tin từ nghiệp vụ Gửi phê duyệt báo giá';

select MA_BAOGIA, HAN_PHEDUYET, TEN_BAOGIA INTO l_ma_baogia, l_han_phe_duyet, l_ten_bao_gia
from BAOGIA bg
WHERE bg.BAOGIA_ID = p_bao_gia_id AND bg.PHANVUNG_ID = p_phanvung_id;

dbms_output.put_line(3);
                    -- lay so dt gui sms
SELECT nhanvien.so_dt INTO l_so_dt
FROM admin.nhanvien
         JOIN BAOGIA ON (nhanvien.nhanvien_id = BAOGIA.nhanvien_id AND nhanvien.DONVI_ID = BAOGIA.DONVI_ID)
         JOIN admin.NHANVIEN_LNV ON nhanvien.nhanvien_id = NHANVIEN_LNV.nhanvien_id
WHERE BAOGIA.BAOGIA_ID = p_bao_gia_id and NHANVIEN_LNV.loainv_id = 104 and rownum = 1 AND BAOGIA.PHANVUNG_ID = p_phanvung_id;

l_noidung := 'Báo giá đã phê duyệt : ' || l_ma_baogia || ' ' || l_ten_bao_gia || ' ' || l_han_phe_duyet || ' ' || p_url;

                    send_sms(p_phanvung_id, l_so_dt, l_noidung, l_ghichu, p_may_cn, p_nguoi_cn, p_ip_cn);
                 -- update lịch sử báo giá GP
                    PKG_OS_TCKH.SP_INSERT_UPDATE_BAO_GIA_GP(
                        p_bao_gia_id,
                        p_phanvung_id,
                        p_ngay_cn,
                        null,
                        0,
                        p_nhan_vien_id,
                        0,
                        0,
                        2,
                        p_ngay_cn,
                        p_nhan_vien_id,
                        p_don_vi_thuc_thi,
                        p_y_kien,
                        p_may_cn,
                        p_nguoi_cn,
                        p_ip_cn,
                        p_ngay_cn,
                        0
                        );

                l_result := 'TRUE';
ELSE
select MA_BAOGIA INTO l_ma_baogia
from BAOGIA
WHERE BAOGIA_ID = p_bao_gia_id AND PHANVUNG_ID = p_phanvung_id;
l_result := 'Các mã báo giá sau : ' || l_ma_baogia ||' không hợp lệ! vui lòng kiểm tra lại';
END IF;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
--                    l_result := 'FALSE';
l_result := 'Co Loi xay ra ' ||sqlerrm;
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;
-- api trả phiếu báo giá
FUNCTION FN_TRA_PHIEU_BAO_GIA_SEL_CHK(
	p_bao_gia_id IN NUMBER,
    p_url           IN VARCHAR2,
    p_phanvung_id   IN NUMBER,
    p_may_cn        IN VARCHAR2,
    p_nguoi_cn      IN VARCHAR2,
    p_ip_cn         IN VARCHAR2,
    p_ngay_cn	    IN DATE,
    p_y_kien        IN VARCHAR2,
    p_don_vi_thuc_thi  IN NUMBER,
    p_nhan_vien_id   IN NUMBER)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_so_dt VARCHAR2(20);
    l_count_record NUMBER;
    l_noidung VARCHAR2(200);
    l_ghichu VARCHAR2(200);
    l_ma_baogia VARCHAR2(2000);
    l_han_phe_duyet DATE;
    l_ten_bao_gia VARCHAR2(500);
BEGIN
BEGIN
SAVEPOINT ABC;
--get danh sach id bao gia
SELECT count(BAOGIA_ID) INTO l_count_record
FROM BAOGIA bg
WHERE bg.BAOGIA_ID = p_bao_gia_id and bg.TTBG_ID = 5 ;

dbms_output.put_line(1);
        -- Truong hop co ton tai iid bao gia
        IF l_count_record <> 0 THEN

            -- Update trang thai bao gia (5) -> (1)
UPDATE BAOGIA
SET BAOGIA.TTBG_ID = 1,
    BAOGIA.NGAY_CN = p_ngay_cn,
    BAOGIA.NGUOI_CN = p_nguoi_cn
WHERE BAOGIA.BAOGIA_ID = p_bao_gia_id and BAOGIA.phanvung_id = p_phanvung_id  ;
dbms_output.put_line(2);
            -- Gui sms
            l_ghichu := 'Nhắn tin từ nghiệp vụ Gửi trả phiếu báo giá';

select MA_BAOGIA, HAN_PHEDUYET, TEN_BAOGIA INTO l_ma_baogia, l_han_phe_duyet, l_ten_bao_gia
from BAOGIA bg
WHERE bg.BAOGIA_ID = p_bao_gia_id and bg.phanvung_id = p_phanvung_id;

dbms_output.put_line(4);
                -- update lịch sử báo giá GP
                PKG_OS_TCKH.SP_INSERT_UPDATE_BAO_GIA_GP(
                        p_bao_gia_id,
                        p_phanvung_id,
                        null,
                        null,
                        0,
                        p_nhan_vien_id,
                        0,
                        0,
                        3,
                        p_ngay_cn,
                        p_nhan_vien_id,
                        p_don_vi_thuc_thi,
                        p_y_kien,
                        p_may_cn,
                        p_nguoi_cn,
                        p_ip_cn,
                        p_ngay_cn,
                        0
                        );
                l_result := 'TRUE';
ELSE
select MA_BAOGIA INTO l_ma_baogia
from BAOGIA
WHERE BAOGIA_ID = p_bao_gia_id and phanvung_id = p_phanvung_id;
l_result := 'Các mã báo giá sau : ' || l_ma_baogia ||' không hợp lệ! vui lòng kiểm tra lại';
END IF;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
--                    l_result := 'FALSE';
l_result := 'Co Loi xay ra ' ||sqlerrm;
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;
-- api hủy báo giá
FUNCTION FN_HUY_BAO_GIA_SEL_CHK(
	p_bao_gia_id IN NUMBER,
    p_nguoi_cn      IN VARCHAR2,
    p_ngay_cn	    IN DATE,
	p_phanvung_id IN NUMBER)
    return VARCHAR2
    IS
	l_result VARCHAR2(4000);
    l_count_record NUMBER;
    l_ma_baogia VARCHAR2(500);
BEGIN
BEGIN
SAVEPOINT ABC;
--get danh sach id bao gia
SELECT count(BAOGIA_ID) INTO l_count_record
FROM BAOGIA bg
WHERE bg.BAOGIA_ID = p_bao_gia_id and bg.TTBG_ID = 5 AND PHANVUNG_ID = p_phanvung_id;

dbms_output.put_line(1);
        -- Truong hop co ton tai iid bao gia
        IF l_count_record <> 0 THEN

            -- Update trang thai bao gia (5) -> (9)
UPDATE BAOGIA
SET BAOGIA.TTBG_ID = 9,
    BAOGIA.NGAY_CN = p_ngay_cn,
    BAOGIA.NGUOI_CN = p_nguoi_cn
WHERE BAOGIA.BAOGIA_ID = p_bao_gia_id AND BAOGIA.PHANVUNG_ID = p_phanvung_id;
dbms_output.put_line(2);

                l_result := 'TRUE';
ELSE
select MA_BAOGIA INTO l_ma_baogia
from BAOGIA
WHERE BAOGIA_ID = p_bao_gia_id;
l_result := 'Các mã báo giá sau : ' || l_ma_baogia ||' không hợp lệ! vui lòng kiểm tra lại';
END IF;

EXCEPTION
            WHEN OTHERS THEN
BEGIN
ROLLBACK TO ABC;
--ulog.plog.error(vc_tmp);
--                    l_result := 'FALSE';
l_result := 'Co Loi xay ra ' ||sqlerrm;
RETURN l_result;
END;
END;
COMMIT;
RETURN l_result;
END;
--api70
PROCEDURE SP_GET_TRA_CUU_BAO_GIA_LIST(
    p_trang_thai_bao_gia IN NUMBER,
    p_ma_bao_gia IN VARCHAR,
    p_nguon_bao_gia IN NUMBER,
    p_don_vi_de_xuat IN NUMBER,
    p_nhan_vien_de_xuat IN NUMBER,
    p_don_vi_phe_duyet IN NUMBER,
    p_ten_khach_hang IN VARCHAR,
    p_ma_khach_hang IN VARCHAR,
    p_tu_ngay IN DATE,
    p_den_ngay IN DATE,
    p_pn_page_id IN NUMBER,
    p_pn_rec_per_page IN NUMBER,
    p_phan_vung_id IN NUMBER,
    v_cusor     OUT SYS_REFCURSOR,
    v_total     OUT number)
IS
    l_result      SYS_REFCURSOR;
    l_sql         VARCHAR2(20000);
BEGIN
    --Lay thong tin danh sach nhan vien
BEGIN
        l_sql := 'select bg.baogia_id idBaoGia,
                    bg.MA_BAOGIA maBaoGia,
                    kh.TEN_KH tenKhachHang,
                    lh.loaihinh_tb tenLoaiHinh,
                    cttbg.mota moTa,
                    bggc.soluong soLuong,
                    bggc.tien donGia,
                    (cttbg.tien + cttbg.vat) thanhTien,
                    TO_CHAR(bg.ngay_cn, ''DD/MM/YYYY'') ngayBaogGia
                    from css.baogia bg
                    left join css.baogia_gp bggp on bggp.baogia_id = bg.baogia_id
                    join css.ct_tienbg cttbg on (bg.baogia_id = cttbg.baogia_id and bg.PHANVUNG_ID = cttbg.PHANVUNG_ID)
                    join css.baogia_gc bggc on bggc.baogia_gc_id = cttbg.id
                    join css.loaihinh_tb lh on bggc.loaihinhtb_id = lh.loaitb_id
                    join css.dichvu_vt dvvt on  bggc.DICHVUVT_ID = dvvt.DICHVUVT_ID
                    join css.db_khachhang kh on (bg.khachhang_id = kh.khachhang_id and bg.PHANVUNG_ID = kh.PHANVUNG_ID)
                    where cttbg.loai_id = 1 and cttbg.khoanmuctt_id = 21 ';

       -- Search trang thai bao gia
        IF p_trang_thai_bao_gia IS NOT NULL THEN
            l_sql := l_sql || ' and bg.TTBG_ID = ' || p_trang_thai_bao_gia;
END IF;

        -- Search ma bao gia
        IF p_ma_bao_gia IS NOT NULL THEN
            l_sql := l_sql || ' and lower(bg.MA_BAOGIA) LIKE ''%' || lower(p_ma_bao_gia) || '%''';
END IF;

        -- Search nguon bao gia
        IF p_nguon_bao_gia IS NOT NULL THEN
            l_sql := l_sql || ' and bg.NGUON = ' || p_nguon_bao_gia;
END IF;

        -- Search don vi de xuat
        IF p_don_vi_de_xuat IS NOT NULL THEN
            l_sql := l_sql || ' and bggp.DONVI_GIAO_ID  = ' || p_don_vi_de_xuat;
END IF;

        -- Search nhan vien de xuat
        IF p_nhan_vien_de_xuat IS NOT NULL THEN
            l_sql := l_sql || ' and bggp.NHANVIEN_GIAO_ID  = ' || p_nhan_vien_de_xuat;
END IF;

        -- Search don vi phe duyet
        IF p_don_vi_phe_duyet IS NOT NULL THEN
            l_sql := l_sql || ' and bggp.DONV_TH_ID    = ' || p_don_vi_phe_duyet;
END IF;

        -- Search ten khach hang
        IF p_ten_khach_hang IS NOT NULL THEN
            l_sql := l_sql || ' and lower(kh.ten_kh) LIKE ''%' || lower(p_ten_khach_hang) || '%''';
END IF;

        -- Search ten khach hang
        IF p_ma_khach_hang IS NOT NULL THEN
            l_sql := l_sql || ' and lower(kh.ma_kh) LIKE ''%' || lower(p_ma_khach_hang) || '%''';
END IF;

        -- Search theo phan vung
        IF p_phan_vung_id IS NOT NULL THEN
            l_sql := l_sql || ' and bg.PHANVUNG_ID = ' || p_phan_vung_id;
END IF;

        -- Search theo tu ngay
        IF p_tu_ngay IS NOT NULL THEN
            l_sql := l_sql || ' AND TO_DATE(bg.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

        -- Search theo den ngay
        IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(bg.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;

        l_sql := l_sql || ' order by bg.ngay_cn desc';
    --lay count data truoc khi qua phan trang
        dbms_output.put_line(v_total);
        v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);
        --lay data cusor sau phan trang
        dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;


EXCEPTION
        WHEN OTHERS THEN
BEGIN
            --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                 || sqlerrm
                                 || ')'' name from dual';
v_total := 0;
            v_cusor := l_result;

END;
END;
END;
-- api 71
PROCEDURE SP_GET_LICH_SU_BAO_GIA_TCKH_LIST(
    p_so_may_or_acc IN VARCHAR2,
    p_dia_chi_lap_dat IN VARCHAR2,
    p_so_giay_to IN VARCHAR2,
    p_ma_so_thue IN VARCHAR2,
    p_ct_hanh_dong IN VARCHAR2,
    p_ten_thanh_toan IN VARCHAR2,
    p_dich_vu IN NUMBER,
    p_ten_khach_hang IN VARCHAR2,
    p_ma_khach_hang IN VARCHAR2,
    p_tu_ngay IN DATE,
    p_den_ngay IN DATE,
    p_pn_page_id IN NUMBER,
    p_pn_rec_per_page IN NUMBER,
    p_phan_vung_id IN NUMBER,
    v_cusor     OUT SYS_REFCURSOR,
    v_total     OUT number)
IS
    l_result      SYS_REFCURSOR;
    l_sql         VARCHAR2(20000);
BEGIN
    --Lay thong tin danh sach nhan vien
BEGIN
        l_sql := 'select a.*, a.dongia *(100 - a.chietKhau) tongSotienThanhToan from (
        select
            bg.baogia_id,
            bg.ten_baogia,
            bg.ma_baogia maBaoGia,
            kh.TEN_KH tenKhachHang,
            lh.loaihinh_tb loaiHinh,
            dvvt.TEN_DVVT,
            cttbg.mota moTa,
            nvl(bggc.soluong,0) soLuong,
            nvl(bggc.tien,0) dongia,
            nvl(bgctkm.CK,0) chietKhau,
            bg.ngay_cn ngayBaoGia
            from css.baogia bg
            left join css.baogia_gp bggp on bggp.baogia_id = bg.baogia_id
            Join css.ct_tienbg cttbg on bg.baogia_id = cttbg.baogia_id and cttbg.phanvung_id = bg.phanvung_id
            join css.baogia_gc bggc on bggc.baogia_gc_id = cttbg.id
            Left join css.baogia_ctkm bgctkm on bggc.baogia_gc_id = bgctkm.baogia_gc_id
            Join css.loaihinh_tb lh on bggc.loaihinhtb_id = lh.loaitb_id
            Join css.dichvu_vt dvvt on  bggc.DICHVUVT_ID = dvvt.DICHVUVT_ID
            Join css.db_khachhang kh on bg.khachhang_id = kh.khachhang_id AND kh.phanvung_id = bg.phanvung_id
            where cttbg.loai_id=1 and cttbg.khoanmuctt_id=21
            and bg.phanvung_id = ' || p_phan_vung_id ;

       -- Search so_dt
        IF p_so_may_or_acc IS NOT NULL THEN
            l_sql := l_sql || ' and lower(kh.SO_DT) LIKE ''%' || lower(p_so_may_or_acc) || '%''';
END IF;

        -- Search diachi_kh
        IF p_dia_chi_lap_dat IS NOT NULL THEN
            l_sql := l_sql || ' and lower(kh.DIACHI_KH) LIKE ''%' || lower(p_dia_chi_lap_dat) || '%''';
END IF;

        -- Search so giay to
        IF p_so_giay_to IS NOT NULL THEN
            l_sql := l_sql || ' and lower(kh.so_gt) LIKE ''%' || lower(p_so_giay_to) || '%''';
END IF;

        -- Search ma so thue
        IF p_ma_so_thue IS NOT NULL THEN
            l_sql := l_sql || ' and lower(kh.mst) LIKE ''%' || lower(p_ma_so_thue) || '%''';
END IF;

        -- Search ten khach hang
        IF p_ten_khach_hang IS NOT NULL THEN
            l_sql := l_sql || ' and lower(kh.TEN_KH) LIKE ''%' || lower(p_ten_khach_hang) || '%''';
END IF;

        -- Search ten khach hang
        IF p_ma_khach_hang IS NOT NULL THEN
            l_sql := l_sql || ' and lower(kh.MA_KH) LIKE ''%' || lower(p_ma_khach_hang) || '%''';
END IF;

        -- Search theo tu ngay
        IF p_tu_ngay IS NOT NULL THEN
            l_sql := l_sql || ' AND TO_DATE(bg.ngay_cn, ''DD-MON-YY'') >= TO_DATE(''' || p_tu_ngay || ''',''DD-MON-YY'')';
END IF;

        -- Search theo den ngay
        IF p_den_ngay IS NOT NULL THEN
                l_sql := l_sql || ' AND TO_DATE(bg.ngay_cn, ''DD-MON-YY'') <= TO_DATE(''' || p_den_ngay || ''',''DD-MON-YY'')';
END IF;
        -- Search dich vu
        IF p_dich_vu > 0 then
             l_sql := l_sql || ' and dvvt.DICHVUVT_ID = ' || p_dich_vu;
END IF;

        l_sql := l_sql || ' ) a ';
    --lay count data truoc khi qua phan trang
        dbms_output.put_line(v_total);
        v_total := PKG_OS_COMMON.SF_COUNT_TOTAL_RECORD_SEL(l_sql);
        --lay data cusor sau phan trang
        dbms_output.put_line(PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page));
OPEN l_result FOR PKG_OS_COMMON.sf_page_separate(l_sql, p_pn_page_id, p_pn_rec_per_page);
v_cusor := l_result;


EXCEPTION
        WHEN OTHERS THEN
BEGIN
            --ulog.plog.error(vc_tmp);
OPEN l_result FOR 'select ''Co Lo xay ra('
                                 || sqlerrm
                                 || ')'' name from dual';
v_total := 0;
            v_cusor := l_result;

END;
END;
END;
END PKG_OS_TCKH;