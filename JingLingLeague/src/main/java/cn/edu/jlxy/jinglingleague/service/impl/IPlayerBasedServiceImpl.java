package cn.edu.jlxy.jinglingleague.service.impl;

import cn.edu.jlxy.jinglingleague.dao.IPlayerDao;
import cn.edu.jlxy.jinglingleague.entity.Player;
import cn.edu.jlxy.jinglingleague.service.IPlayerBasedService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

/**
 * Created by neo on 2017/2/28.
 */
@Service
public class IPlayerBasedServiceImpl implements IPlayerBasedService{
    @Resource
    IPlayerDao dao;

    public Player login(Player player) {
        Player p =dao.login(player);
        return p != null? p : null;
    }

    public boolean register(Player player) {
        return dao.register(player) == 1? true : false;
    }

    public boolean updatePwd(Player player) {
        return false;
    }
}
