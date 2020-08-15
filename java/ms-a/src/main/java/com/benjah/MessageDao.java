package com.benjah;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

import org.springframework.jdbc.core.PreparedStatementCreatorFactory;
import org.springframework.jdbc.core.SqlParameter;

import org.springframework.jdbc.core.simple.SimpleJdbcInsert;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.Types;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;


@Repository
public class MessageDao {

	   /**
     * 声明 INSERT 操作的 PreparedStatementCreatorFactory 对象
     */
    private static final PreparedStatementCreatorFactory INSERT_PREPARED_STATEMENT_CREATOR_FACTORY
            = new PreparedStatementCreatorFactory("INSERT INTO messages(msg_id, message, create_time) VALUES(?, ?, ?)");

    static {
        // 设置返回主键
        INSERT_PREPARED_STATEMENT_CREATOR_FACTORY.setReturnGeneratedKeys(true);
        INSERT_PREPARED_STATEMENT_CREATOR_FACTORY.setGeneratedKeysColumnNames("id");
        // 设置每个占位符的类型
        INSERT_PREPARED_STATEMENT_CREATOR_FACTORY.addParameter(new SqlParameter(Types.INTEGER));
        INSERT_PREPARED_STATEMENT_CREATOR_FACTORY.addParameter(new SqlParameter(Types.VARCHAR));
        INSERT_PREPARED_STATEMENT_CREATOR_FACTORY.addParameter(new SqlParameter(Types.TIMESTAMP));
    }

    @Autowired
    private JdbcTemplate template;

    /**
     * 使用 PreparedStatementCreator 实现插入数据
     *
     * @param entity 实体
     * @return 影响行数
     */
    public int insert(MessageDO entity) {
        // 创建 KeyHolder 对象，设置返回的主键 ID
        KeyHolder keyHolder = new GeneratedKeyHolder();
        // 执行插入操作
        int updateCounts = template.update(INSERT_PREPARED_STATEMENT_CREATOR_FACTORY.newPreparedStatementCreator(
                Arrays.asList(entity.getMsgId(), entity.getMessage(), entity.getCreateTime())
        ), keyHolder);
        // 设置 ID 主键到 entity 实体中
        if (keyHolder.getKey() != null) {
            entity.setId(keyHolder.getKey().intValue());
        }
        // 返回影响行数
        return updateCounts;
    }

    /**
     * 使用 SimpleJdbcInsert 实现插入数据
     *
     * @param entity 实体
     * @return 影响行数
     */
    public int insert0(MessageDO entity) {
        // 创建 SimpleJdbcInsert 对象
        SimpleJdbcInsert insertOp = new SimpleJdbcInsert(template);
        insertOp.setTableName("messages");
        insertOp.setColumnNames(Arrays.asList("msg_id", "message", "create_time"));
        insertOp.setGeneratedKeyName("id");
        // 拼接参数
        Map<String, Object> params = new HashMap<>();
        params.put("msg_id", entity.getMsgId());
        params.put("message", entity.getMessage());
        params.put("create_time", entity.getCreateTime());
        // 执行插入操作
        Number id = insertOp.executeAndReturnKey(params);
        // 设置 ID 主键到 entity 实体中
        entity.setId(id.intValue());
        // 返回影响行数
        return 1;
    }

}
