/****** Object:  StoredProcedure [dbo].[SCFN_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SCFN_RETRIEVE_S1] (
 @An_Office_IDNO       NUMERIC(3, 0),
 @Ac_SignedOnWorker_ID CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : SCFN_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve the screen function details for the given worker and office.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Lc_TableFtic_ID    CHAR(4) = 'FTIC',
          @Li_One_NUMB        INT     =1,
          @Ld_Systemdate_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT X.Screen_ID,
         X.ScreenFunction_CODE,
         X.ScreenFunction_NAME,
         X.AccessAdd_INDC,
         X.AccessDelete_INDC,
         X.AccessView_INDC,
         X.AccessModify_INDC,
         X.NoPosition_IDNO,
         X.Access_INDC,
         (SELECT COUNT (1)
            FROM REFM_Y1 r
           WHERE r.Table_ID = @Lc_TableFtic_ID
             AND r.TableSub_ID = @Lc_TableFtic_ID
             AND r.Value_CODE = X.Screen_ID) FticCount_QNTY
    FROM (SELECT ROW_NUMBER () OVER ( PARTITION BY c.Screen_ID, c.ScreenFunction_CODE
										ORDER BY b.Access_INDC DESC,
												 c.AccessView_INDC DESC,
												 c.AccessModify_INDC DESC,
												 c.AccessAdd_INDC DESC,
												 c.AccessDelete_INDC DESC ) AS Row_NUMB,
                 c.Screen_ID,
                 c.ScreenFunction_CODE,
                 c.ScreenFunction_NAME,
                 b.Access_INDC,
                 c.AccessAdd_INDC,
                 c.AccessDelete_INDC,
                 c.AccessView_INDC,
                 c.AccessModify_INDC,
                 c.NoPosition_IDNO
            FROM SCFN_Y1 c
                 LEFT OUTER JOIN (SELECT b.Access_INDC,
                                         b.Screen_ID,
                                         b.ScreenFunction_CODE
                                    FROM USRL_Y1 a
                                         JOIN RLSA_Y1 b
                                          ON a.Role_ID = b.Role_ID
                                   WHERE a.Worker_ID = @Ac_SignedOnWorker_ID
                                     AND a.Office_IDNO = @An_Office_IDNO
                                     AND a.Effective_DATE <= @Ld_Systemdate_DATE
                                     AND a.Expire_DATE > @Ld_Systemdate_DATE
                                     AND a.EndValidity_DATE = @Ld_High_DATE
                                     AND b.EndValidity_DATE = @Ld_High_DATE) AS b
                  ON b.Screen_ID = c.Screen_ID
                     AND b.ScreenFunction_CODE = c.ScreenFunction_CODE
           WHERE c.EndValidity_DATE = @Ld_High_DATE)AS X
   WHERE X.Row_NUMB = @Li_One_NUMB
   ORDER BY Row_NUMB;
 END; --End Of SCFN_RETRIEVE_S1

GO
